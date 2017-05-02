# coding: utf-8

module MicroRb
  module Servers
    class Error < StandardError
      attr_accessor :code, :message

      def initialize(code, message)
        self.code    = code
        self.message = message

        super(message)
      end

      def to_h
        { code: code, message: message }
      end

      class ParseError < Error
        def initialize
          super(-32_700, 'Invalid JSON was received by the server. '\
              'An error occurred on the server while parsing the JSON text.')
        end
      end

      class InvalidParams < Error
        def initialize
          super(-32_602, 'Invalid method parameter(s).')
        end
      end

      class ServerError < Error
        def initialize(code, message)
          super(code, message)
        end
      end

      class InvalidRequest < Error
        def initialize
          super(-32_600, 'The JSON sent is not a valid Request object.')
        end
      end

      class InternalError < Error
        def initialize(e)
          super(-32_603, "Internal server error: #{e}")
        end
      end

      class MethodNotFound < Error
        def initialize(method)
          super(-32_601, "Method '#{method}' not found.")
        end
      end
    end
  end
end
