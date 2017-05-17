# coding: utf-8
# frozen_string_literal: true

module MicroRb
  class Configuration
    include Singleton

    # Sidecar settings
    attr_accessor :sidecar_registry, :sidecar_host, :sidecar_port

    # Micro API settings
    attr_accessor :api_host, :api_port, :api_rpc

    def self.configure
      yield(instance) if block_given?
    end

    def sidecar_uri
      "#{sidecar_host}:#{sidecar_port}"
    end

    def sidecar_registry_uri
      "#{sidecar_uri}#{sidecar_registry}"
    end

    def api_uri
      "#{api_host}:#{api_port}"
    end

    def api_rpc_uri
      "#{api_uri}#{api_rpc}"
    end

    private

    def initialize
      yield(self) if block_given?

      # Default sidecar settings
      self.sidecar_host     ||= 'http://127.0.0.1'
      self.sidecar_registry ||= '/registry'
      self.sidecar_port     ||= '8081'

      # Default micro API settings
      self.api_host ||= 'http://127.0.0.1'
      self.api_rpc  ||= '/rpc'
      self.api_port ||= '3002'
    end
  end
end
