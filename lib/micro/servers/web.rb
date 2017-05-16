# coding: utf-8
# frozen_string_literal: true

require 'rack'
require 'rack/request'
require 'rack/response'

module MicroRb
  module Servers
    class Web
      attr_accessor :service_config, :server

      def initialize(service_config)
        self.service_config = service_config
        server_opts = service_config.options.merge(Host: service_config.host, Port: service_config.port, app: self)
        self.server = Rack::Server.new(server_opts)
      end

      def start!
        service_config.register!
        server.start
      end

      #
      # Entry point for Rack
      #
      def call(env)
        req  = Rack::Request.new(env)
        resp = Rack::Response.new

        return resp.finish unless req.post?

        request  = req.body.read
        response = service_config.request_manager.handle_request(request)

        resp.write(response)
        resp.finish
      end
    end
  end
end
