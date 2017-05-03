# coding: utf-8

module MicroRb
  module Sidecar
    class Register
      include MicroRb::Sidecar::Base

      def self.notify(service)
        post(registry_uri, options(service))
      end

      def self.remove(service)
        delete(registry_uri, options(service))
      end
    end
  end
end
