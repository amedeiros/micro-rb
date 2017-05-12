# coding: utf-8
# frozen_string_literal: true

require 'httparty'

module MicroRb
  module Clients
    module Base
      extend ActiveSupport::Concern

      CONTENT_TYPE = 'application/json'

      included do
        include HTTParty

        def self.options(body)
          { body: body.to_json, headers: { 'Content-Type' => CONTENT_TYPE } }
        end

        def self.decode(json)
          MultiJson.decode(json)
        end
      end
    end
  end
end
