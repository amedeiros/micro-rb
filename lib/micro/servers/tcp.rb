# coding: utf-8
# frozen_string_literal: true

require 'celluloid/current'
require 'celluloid/io'

module MicroRb
  module Servers
    class TCP
      include Celluloid::IO

      attr_reader :server, :service_config

      finalizer :shutdown

      def initialize(service_config)
        @service_config  = service_config
        @server          = TCPServer.new(service_config.host, service_config.port)
      end

      def shutdown
        @server&.close
      end

      def start!
        service_config.register!
        loop { async.handle_connection @server.accept }
      end

      private

      def handle_connection(socket)
        _, port, host = socket.peeraddr
        MicroRb.logger.debug("*** Received connection from #{host}:#{port}")

        loop do
          request  = socket.readpartial(4096)
          response = service_config.request_manager.handle_request(request)
          socket.write(response)
          socket.flush
        end
      rescue EOFError => e
        MicroRb.logger.debug("*** #{host}:#{port} disconnected", e)
        socket.close
      end
    end
  end
end
