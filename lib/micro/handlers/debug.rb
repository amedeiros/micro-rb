# coding: utf-8

require 'micro/proto/debug_pb'

module MicroRb
  module Handlers
    class Debug
      include MicroRb::Handler
      include MicroRb::Debug

      handler name: :debug, metadata: { about: 'Health check endpoint' }, rpc_method: :health

      def health(request: Request.new, response: Response.new)
        response.status = 'ok' # default

        response
      end

      # Override this to set Health capital.
      def full_rpc_name
        "#{self.class.to_s.split('::').last}.Health"
      end
    end
  end
end
