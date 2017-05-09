require_relative '../proto/sum_pb'

module <%= @class_name %>
  # Example MicroRb handler
  class ExampleHandler
    include MicroRb::Handler
    include <%= @class_name %>::SumHandler
    handler name: :example, metadata: { hello: 'Micro-Rb' }, rpc_method: :sum

    def sum(request: Request.new, response: Response.new)
      response.total = request.a + request.b

      response
    end
  end
end
