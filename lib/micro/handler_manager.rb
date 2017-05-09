

module MicroRb
  class HandlerManager
    attr_reader :handlers, :rpc_methods

    def initialize
      @handlers    = { }
      @rpc_methods = { }
    end

    def add_handler(handler)
      unless handler.is_a?(MicroRb::Handler)
        raise "Handler must be of type MicroRb::Handler got #{handler.class}"
      end

      if handlers.key?(handler.name)
        raise "Handler #{handler.name} has already been registered."
      end

      handler.rpc_methods.each do |method|
        if rpc_methods.key?(method)
          raise "Method #{method} has already been registered."
        end

        rpc_methods[method.to_sym] = handler.method(method)
      end

      handlers[handler.name] = handler
    end

    def endpoints
      points = []

      handlers.values.each do |handler|
        handler.rpc_methods.each do |method|
          point = { name: method, request: handler.request_structure, response: handler.response_structure}
          points << point
        end
      end

      points
    end

    def rpc_method(method)
      rpc_methods[method.to_sym]
    end

    def rpc_method?(method)
      rpc_methods.key?(method.to_sym)
    end

    def rpc_method_response(method)
      rpc_method(method).owner::Response.new
    end

    def rpc_method_request(method, params)
      rpc_method(method).owner::Request.new(*params)
    end
  end
end