# coding: utf-8
# frozen_string_literal: true

module MicroRb
  module Clients
    class Rpc
      include Base

      base_uri MicroRb::Configuration.instance.api_uri

      def self.call(service:, method:, params:, klass_response: nil)
        response = post(MicroRb::Configuration.instance.api_rpc,
                        options(service: service, method: method, request: params))

        return klass_response.new(response.to_h.symbolize_keys!) if klass_response

        response
      end
    end
  end
end
