module <%= @class_name %>
  # Example MicroRb handler
  class ExampleHandler
    include MicroRb::Handler
    handler name: :example

    def sum(request, params)
      { total: params['a'] + params['b'] }
    end
  end
end
