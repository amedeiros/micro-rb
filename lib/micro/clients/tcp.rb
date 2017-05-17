# coding: utf-8
# frozen_string_literal: true

require 'celluloid/current'
require 'celluloid/io'

module MicroRb
  module Clients
    class TCP
      attr_reader :host, :port

      def initialize(host, port)
        @host = host
        @port = port
      end

      def call(service:, method:, params:, klass_response: nil)
        response = nil

        Celluloid::IO::TCPSocket.open(host, port) do |sock|
          msg = { service: service, method: method, params: params }
          json = MultiJson.encode(msg)
          sock.write(json)
          response = MultiJson.decode(sock.readpartial(4096))
        end

        return klass_response.new(response.to_h.symbolize_keys!) if klass_response

        response
      end

      def self.call(service:, method:, params:, host:, port:, klass_response: nil)
        new(host, port)
          .call(service: service, method: method,
                params: params, klass_response: klass_response)
      end
    end
  end
end
