# coding: utf-8
# frozen_string_literal: true

module MicroRb
  module Sidecar
    class Call
      include MicroRb::Sidecar::Base

      def self.rpc(path, request)
        post(path, options(request))
      end

      def self.http(path, request)
        post(path, query: request)
      end
    end
  end
end
