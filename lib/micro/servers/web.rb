# coding: utf-8
# frozen_string_literal: true

require 'rack'
require 'rack/request'
require 'rack/response'
require 'multi_json'

module MicroRb
  module Servers
    class Web
      attr_accessor :host, :port, :show_errors, :debug, :metadata, :version,
                    :request_manager, :name, :node_id, :server

      def initialize(name, opts = {})
        self.port     = opts.delete(:port)     || 3000
        self.host     = opts.delete(:host)     || '0.0.0.0'
        self.metadata = opts.delete(:metadata) || {}
        self.version  = opts.delete(:version)  || '0.0.1'
        self.debug    = opts.delete(:debug)
        self.name     = name
        self.node_id  = "#{name}-#{SecureRandom.uuid}"
        self.request_manager = MicroRb::RequestManager.new

        server_opts = opts.merge(Host: host, Port: port, app: self)
        self.server = Rack::Server.new(server_opts)
      end

      def add_handler(handler)
        request_manager.handler_manager.add_handler(handler)
      end

      def start!
        # Register the debug handler. This is kinda poor.
        add_handler(MicroRb::Handlers::Debug.new)

        # Value will raise an error on anything not 2XX
        MicroRb::Clients::Sidecar.register(self).response.value

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
          nodes: [{ id: node_id, address: host, port: port }],
          endpoints: request_manager.handler_manager.endpoints
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

        request  = req.body.read
        response = request_manager.handle_request(request)

        resp.write(response)
        resp.finish
      end

      private

      def add_finalizer_hook!
        at_exit do
          MicroRb.logger.debug("Shutting down #{name}:#{host}:#{port}") if debug
          MicroRb::Clients::Sidecar.remove(self)
        end
      end
    end
  end
end
