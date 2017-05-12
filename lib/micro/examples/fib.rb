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

    left = MicroRb::Clients::Rpc.call(service: :test,
                                      method: 'FibHandler.fibonacci',
                                      params: Request.new(n: request.n - 1),
                                      klass_response: Response).n

    right = MicroRb::Clients::Rpc.call(service: :test,
                                       method: 'FibHandler.fibonacci',
                                       params: Request.new(n: request.n - 2),
                                       klass_response: Response).n

    response.n = left + right

    response
  end
end

server = MicroRb::Servers::Web.new(:test, debug: true, metadata: { example: 'Fib Service' }, server: :puma)
server.add_handler FibHandler.new
server.start!

# MicroRb::Clients::Rpc.call(service: :test, method: 'FibHandler.fibonacci', params: { n:  15 } )
# {
#     "n" => 610
# }
