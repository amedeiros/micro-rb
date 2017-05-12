# coding: utf-8
# frozen_string_literal: true

module MicroRb
  module Clients
    class Http
      include Base

      def self.call(uri:, service:, method:, params:, klass_response: nil)
        response = decode(post(uri, options(service: service, method: method, params: Array.wrap(params))))

        return klass_response.new(response.to_h.symbolize_keys!) if klass_response

        response
      end
    end
  end
end
