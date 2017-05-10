# coding: utf-8
# frozen_string_literal: true

module MicroRb
  class Configuration
    include Singleton

    attr_accessor :sidecar_registry
    attr_accessor :sidecar_host
    attr_accessor :sidecar_port

    def self.configure
      yield(instance) if block_given?
    end

    def sidecar_uri
      "#{sidecar_host}:#{sidecar_port}"
    end

    def sidecar_registry_uri
      "#{sidecar_uri}#{sidecar_registry}"
    end

    private

    def initialize
      yield(self) if block_given?

      self.sidecar_host     ||= 'http://127.0.0.1'
      self.sidecar_registry ||= '/registry'
      self.sidecar_port     ||= '8081'
    end
  end
end
