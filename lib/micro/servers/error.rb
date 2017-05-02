# coding: utf-8

module MicroRb
  module Servers
    class Error < StandardError
      attr_accessor :code, :message

      def initialize(code, message)
        @code = code
        @message = message
        super(message)
      end

      def to_h
        {
            'code'    => @code,
            'message' => @message
        }
      end

      class InvalidRequest < Error
        def initialize
          super(-32600, 'The JSON sent is not a valid Request object.')
        end
      end

      class InternalError < Error
        def initialize(e)
          super(-32603, "Internal server error: #{e}")
        end
      end

      class MethodNotFound < Error
        def initialize(method)
          super(-32601, "Method '#{method}' not found.")
        end
      end
    end
  end
end
