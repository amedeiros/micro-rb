# coding: utf-8

module MicroRb
  class Configuration
    attr_accessor :sidecar_registry
    attr_accessor :sidecar_host

    # The default Configuration object.
    def self.default
      @default ||= Configuration.new
    end

    def self.configure
      yield(default) if block_given?
    end

    private

    def initialize
      yield(self) if block_given?

      @sidecar_host     ||= 'http://127.0.0.1:8081'
      @sidecar_registry ||= "#{sidecar_host}/registry"
    end
  end
end
