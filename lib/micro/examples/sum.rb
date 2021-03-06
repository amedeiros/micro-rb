# coding: utf-8
# frozen_string_literal: true

require_relative '../../../lib/microrb'
require_relative '../examples/proto/sum_pb'

class MyHandler
  include MicroRb::Handler
  include MicroRb::SumHandler

  handler name: :test, metadata: { hello: 'Micro-Rb' }, rpc_method: :sum

  def sum(request: Request.new, response: Response.new)
    response.total = request.a + request.b

    response
  end
end

service_config = MicroRb::ServiceConfiguration.new(name: :test, metadata: { example: 'Service' })
service_config.add_handler(MyHandler.new)

server = MicroRb::Servers::Web.new(service_config)
server.start!
