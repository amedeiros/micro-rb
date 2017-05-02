# coding: utf-8

module MicroRb
  module Sidecar
    class Register
      include MicroRb::Sidecar::Base

      def self.notify(service)
        post(REGISTRY, options(service))
      end

      def self.remove(service)
        delete(REGISTRY, options(service))
      end
    end
  end
end
