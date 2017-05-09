# coding: utf-8

require 'rack'
require 'rack/request'
require 'rack/response'
require 'multi_json'

module MicroRb
  module Servers
    class Web
      attr_accessor :host, :port, :show_errors, :debug, :metadata, :version
      attr_accessor :handler_manager, :name, :node_id, :server

      REQUIRED_TYPES = { method: [String], params: [Hash, Array],
                         id: [String, Integer, NilClass] }.freeze

      REQUIRED_KEYS  = ['method'].freeze

      def initialize(name, opts = {})
        self.port     = opts.delete(:port)  || 3000
        self.host     = opts.delete(:host)  || '0.0.0.0'
        self.metadata = opts.delete(:metadata) || {}
        self.version  = opts.delete(:version) || '0.0.1'
        self.debug    = opts.delete(:debug)
        self.name     = name
        self.node_id  = "#{name}-#{SecureRandom.uuid}"
        self.handler_manager = MicroRb::HandlerManager.new

        server_opts = opts.merge(Host: host, Port: port, app: self)
        self.server = Rack::Server.new(server_opts)
      end

      def add_handler(handler)
        handler_manager.add_handler(handler)
      end

      def start!
        # Value will raise an error on anything not 2XX
        MicroRb::Sidecar::Register.notify(self).response.value

        if debug
          MicroRb.logger
                 .debug("Registered #{name}:#{host}:#{port} with sidecar.")
        end

        add_finalizer_hook!
        server.start
      rescue Net::HTTPFatalError => e
        msg = "Sidecar error: #{e.message}"
        MicroRb.logger.warn(msg)

        raise MicroRb::Servers::Error::ServerError.new(-32_000, msg)
      end

      def to_h
        {
          version: version,
          metadata: metadata,
          name: name,
          nodes: [ { id: node_id, address: host, port: port } ],
          endpoints: handler_manager.endpoints
        }
      end

      def to_json
        to_h.to_json
      end

      #
      # Entry point for Rack
      #
      def call(env)
        req  = Rack::Request.new(env)
        resp = Rack::Response.new

        return resp.finish unless req.post?

        resp.write process(req.body.read)
        resp.finish
      end

      def process(content)
        response = handle_request(content)

        MultiJson.encode(response)
      end

      def create_response(request)
        method  = request['method'].strip.to_sym
        params  = request['params'].map(&:symbolize_keys!)

        unless handler_manager.rpc_method?(method)
          return error_response(Error::MethodNotFound.new(method), request)
        end

        rpc_method = handler_manager.rpc_method(method)
        response   = rpc_method.call(request: handler_manager.rpc_method_request(method, params),
                                     response: handler_manager.rpc_method_response(method))

        success_response(request, response)
      end

      def handle_request(request)
        request  = parse_request(request)
        response = nil

        begin
          response = create_response(request) if valid_request?(request)
          response ||= error_response(Error::InvalidRequest.new, request)
        rescue MultiJson::ParseError => e
          MicroRb.logger.warn(e)
          response = error_response(Error::ParseError.new)
        rescue StandardError => e
          MicroRb.logger.warn(e)
          response = error_response(Error::InternalError.new(e), request)
        end

        response
      end

      private

      def valid_request?(request)
        return false unless request.is_a?(Hash)

        REQUIRED_KEYS.each do |key|
          return false unless request.key?(key)
        end

        REQUIRED_TYPES.each do |key, types|
          return false if request.key?(key) &&
                          types.none? { |type| request[key].is_a?(type) }
        end

        true
      end

      def success_response(request, result)
        { result: result, id: request['id'] }
      end

      def error_response(error, request = {})
        { error: error.to_h, id: request['id'] }
      end

      def add_finalizer_hook!
        at_exit do
          MicroRb.logger.debug("Shutting down #{name}:#{host}:#{port}") if debug
          MicroRb::Sidecar::Register.remove(self)
        end
      end

      def parse_request(request)
        MultiJson.decode(request)
      end
    end
  end
end
