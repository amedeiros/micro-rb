# coding: utf-8
# frozen_string_literal: true

require_relative '../../../lib/microrb'
require_relative '../examples/proto/fib_pb'
require 'rack/handler/puma'

# This example was to show the usage of puma as well as making RPC calls to services.
class FibHandler
  include MicroRb::Handler
  include MicroRb::FibPb

  handler name: :fibonacci, metadata: { hello: 'Micro-Rb' }, rpc_method: :fibonacci

  def fibonacci(request: Request.new, response: Response.new)
    if (0..1).cover?(request.n)
      response.n = request.n

      return response
    end

    left  = rpc_call(Request.new(n: request.n - 1))
    right = rpc_call(Request.new(n: request.n - 2))

    response.n = left + right

    response
  end

  private

  def rpc_call(request)
    MicroRb::Clients::Rpc.call(service: :test,
                               method: 'FibHandler.fibonacci',
                               params: request,
                               klass_response: Response).n
  end
end

service_config = MicroRb::ServiceConfiguration.new(name: test, metadata: { example: 'Fib Service' }, server: :puma)
service_config.add_handler(FibHandler.new)

server = MicroRb::Servers::Web.new(service_config)
server.start!

# MicroRb::Clients::Rpc.call(service: :test, method: 'FibHandler.fibonacci', params: { n:  15 } )
# {
#     "n" => 610
# }
