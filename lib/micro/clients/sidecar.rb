# coding: utf-8
# frozen_string_literal: true

module MicroRb
  module Clients
    class Sidecar
      include Base

      base_uri MicroRb::Configuration.instance.sidecar_uri

      def self.register(service)
        post(registry_path, options(service))
      end

      def self.remove(service)
        delete(registry_path, options(service))
      end

      def self.registry_path
        MicroRb::Configuration.instance.sidecar_registry
      end
    end
  end
end
