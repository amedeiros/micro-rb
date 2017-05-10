# coding: utf-8
# frozen_string_literal: true

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
