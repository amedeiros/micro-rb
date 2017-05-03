# coding: utf-8

module MicroRb
  module Sidecar
    module Base
      extend ActiveSupport::Concern

      CONTENT_TYPE = 'application/json'.freeze

      included do
        include HTTParty

        def self.options(body)
          { body: body.to_json, headers: { 'Content-Type' => CONTENT_TYPE } }
        end

        def self.registry_uri
          MicroRb::Configuration.instance.sidecar_registry_uri
        end
      end
    end
  end
end
