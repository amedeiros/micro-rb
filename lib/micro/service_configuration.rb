# coding: utf-8
# frozen_string_literal: true

module MicroRb
  class ServiceConfiguration
    attr_accessor :name, :port, :host, :metadata,
                  :version, :node_id, :options, :request_manager

    def initialize(options = {})
      self.port     = options.delete(:port)     || 3000
      self.host     = options.delete(:host)     || '0.0.0.0'
      self.metadata = options.delete(:metadata) || {}
      self.version  = options.delete(:version)  || '0.0.1'
      self.name     = options.delete(:name)
      self.node_id  = "#{name}-#{SecureRandom.uuid}"
      self.options  = options
      self.request_manager = MicroRb::RequestManager.new
    end

    def add_handler(handler)
      request_manager.handler_manager.add_handler(handler)
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

    def register!
      # Value will raise an error on anything not 2XX
      MicroRb::Clients::Sidecar.register(self).response.value

      MicroRb.logger.debug("Registered #{name}:#{host}:#{port} with sidecar.")

      add_finalizer_hook!
    rescue Net::HTTPFatalError => e
      msg = "Sidecar error: #{e.message}"
      MicroRb.logger.warn(msg)

      raise MicroRb::Servers::Error::ServerError.new(-32_000, msg)
    end

    private

    def add_finalizer_hook!
      at_exit do
        MicroRb.logger.debug("Shutting down #{name}:#{host}:#{port}")
        MicroRb::Clients::Sidecar.remove(self)
      end
    end
  end
end
