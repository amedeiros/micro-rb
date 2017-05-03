# coding: utf-8

require 'rack'
require 'rack/request'
require 'rack/response'
require 'multi_json'

##############
# INCOMPLETE #
##############
module MicroRb
  module Servers
    class Web
      attr_accessor :host, :port, :show_errors, :debug
      attr_accessor :handlers, :name, :node_id, :server

      REQUIRED_TYPES = { method: [String], params: [Hash, Array],
                         id: [String, Integer, NilClass] }.freeze

      REQUIRED_KEYS  = ['method'].freeze

      def initialize(name, opts = {})
        self.port     = opts.delete(:port)  || 3000
        self.host     = opts.delete(:host)  || '0.0.0.0'
        self.debug    = opts.delete(:debug)
        self.handlers = {}
        self.name     = name
        self.node_id  = "#{name}-#{SecureRandom.uuid}"

        server_opts = opts.merge(Host: host, Port: port, app: self)
        self.server = Rack::Server.new(server_opts)
      end

      def add_handler(handler)
        unless handler.is_a?(MicroRb::Handler)
          raise "Handler must be of type MicroRb::Handler got #{handler.class}"
        end

        if handlers.key?(handler.name)
          raise "Handler #{handler.name} has already been registered."
        end

        handlers[handler.name.to_sym] = handler
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

        raise MicroRb::Servers::Error::ServerError.new(-32000, msg)
      end

      def to_h
        {
          name: name,
          nodes: [
            { id: node_id, address: host, port: port }
          ]
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
        method  = request['method']
        params  = request['params']
        handler = handlers.select { |_, v| v.respond_to?(method.to_s.strip) }
        handler = handler.values.first

        if handler.blank?
          return error_response(Error::MethodNotFound.new(method), request)
        end

        success_response(request, handler.send(method, request, params.first))
      end

      def handle_request(request)
        request  = parse_request(request)
        response = nil

        begin
          if !validate_request(request)
            response = error_response(Error::InvalidRequest.new, request)
          else
            response = create_response(request)
          end
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

      def validate_request(request)
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
