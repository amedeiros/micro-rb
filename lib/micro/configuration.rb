# coding: utf-8
# frozen_string_literal: true

module MicroRb
  class Configuration
    include Singleton

    # Sidecar settings
    attr_accessor :sidecar_registry, :sidecar_host, :sidecar_port

    # API gateway settings
    attr_accessor :gateway_host, :gateway_port, :gateway_rpc

    def self.configure
      yield(instance) if block_given?
    end

    def sidecar_uri
      "#{sidecar_host}:#{sidecar_port}"
    end

    def sidecar_registry_uri
      "#{sidecar_uri}#{sidecar_registry}"
    end

    def gateway_uri
      "#{gateway_host}:#{gateway_port}"
    end

    def gateway_rpc_uri
      "#{gateway_uri}#{gateway_rpc}"
    end

    private

    def initialize
      yield(self) if block_given?

      # Default sidecar settings
      self.sidecar_host     ||= 'http://127.0.0.1'
      self.sidecar_registry ||= '/registry'
      self.sidecar_port     ||= '8081'

      # Default API gateway settings
      self.gateway_host ||= 'http://127.0.0.1'
      self.gateway_rpc  ||= '/rpc'
      self.gateway_port ||= '3002'
    end
  end
end
