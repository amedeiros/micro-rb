require_relative '../proto/sum_pb'

module <%= @class_name %>
  # Example MicroRb handler
  class ExampleHandler
    include MicroRb::Handler
    include <%= @class_name %>::SumHandler
    handler name: :test, metadata: { hello: 'Micro-Rb' }

    def sum(request: Request, response: Response)
      response.total = request.a + request.b

      response
    end
  end
end
