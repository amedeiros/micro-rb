# coding: utf-8

module MicroRb
  module Sidecar
    module Base
      extend ActiveSupport::Concern

      CONTENT_TYPE = 'application/json'.freeze
      REGISTRY     = MicroRb::Configuration.instance.sidecar_registry

      included do
        include HTTParty
        base_uri MicroRb::Configuration.instance.sidecar_uri

        def self.options(body)
          { body: body.to_json, headers: { 'Content-Type' => CONTENT_TYPE } }
        end
      end
    end
  end
end
