# coding: utf-8

module MicroRb
  class HandlerManager
    attr_reader :handlers, :rpc_methods, :endpoints

    def initialize
      @handlers    = []
      @rpc_methods = {}
      @endpoints   = []
    end

    def add_handler(handler)
      validate_handler(handler)
      add_rpc_method(handler)
      add_endpoints(handler)

      handlers << handler.name
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

    private

    def validate_handler(handler)
      unless handler.is_a?(MicroRb::Handler)
        raise "Handler must be of type MicroRb::Handler got #{handler.class}"
      end

      if handlers.include?(handler.name)
        raise "Handler #{handler.name} has already been registered."
      end

      unless handler.valid?
        raise "Handler #{handler.name} is invalid."
      end
    end

    def add_rpc_method(handler)
      rpc_methods[handler.full_rpc_name.to_sym] = handler.method(handler.rpc_method)
    end

    def add_endpoints(handler)
      @endpoints << handler.endpoint_structure
    end
  end
end
