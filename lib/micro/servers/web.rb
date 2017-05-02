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

      def initialize(name, opts={})
        self.port     = opts.delete(:port)  || 3000
        self.host     = opts.delete(:host)  || '0.0.0.0'
        self.debug    = opts.delete(:debug)
        self.handlers = { }
        self.name     = name
        self.node_id  = "#{name}-#{SecureRandom.uuid}"
        self.server   = Rack::Server.new(opts.merge(Host: host, Port: port, app: self))
      end

      def add_handler(handler)
        fail "Handler must be of type MicroRb::Handler got #{handler.class}" unless handler.is_a?(MicroRb::Handler)
        fail "Handler #{handler.name} has already been registered." if handlers.key?(handler.name)

        handlers[handler.name.to_sym] = handler
      end

      def start!
        response = MicroRb::Sidecar::Register.notify(self)
        fail response unless response.blank?

        add_finalizer_hook!
        server.start
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
        request  = parse_request(content)
        response = handle_request(request)

        MultiJson.encode(response)
      end

      def create_response(request)
        method  = request['method']
        params  = request['params']
        handler = handlers.select { |_, v| v.respond_to?(method.to_s.strip) }.values.first

        return error_response(MicroRb::Servers::Error::MethodNotFound.new(method), request) if handler.blank?

        success_response(request, handler.send(method, request, params.first))
      end

      def handle_request(request)
        response = nil

        begin
          if !validate_request(request)
            response = error_response(MicroRb::Servers::Error::InvalidRequest.new, request)
          else
            response = create_response(request)
          end
        rescue StandardError => e
          response = error_response(MicroRb::Servers::Error::InternalError.new(e), request)
        end

        response
      end

      private

      def validate_request(request)
        required_keys  = %w(method)
        required_types = { method: [String], params: [Hash, Array], id: [String, Fixnum, Bignum, NilClass] }

        return false unless request.is_a?(Hash)

        required_keys.each do |key|
          return false unless request.has_key?(key)
        end

        required_types.each do |key, types|
          return false if request.has_key?(key) && !types.any? { |type| request[key].is_a?(type) }
        end

        true
      end

      def success_response(request, result)
        { result: result, id: request['id'] }
      end

      def error_response(error, request)
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
