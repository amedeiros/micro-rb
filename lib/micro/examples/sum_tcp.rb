# coding: utf-8
# frozen_string_literal: true

require_relative '../../../lib/microrb'
require_relative '../examples/proto/sum_pb'

class TcpSumExample
  include MicroRb::Handler
  include MicroRb::SumHandler

  handler name: :test, metadata: { hello: 'Micro-Rb' }, rpc_method: :sum

  def sum(request: Request.new, response: Response.new)
    response.total = request.a + request.b

    response
  end
end

service_config = MicroRb::ServiceConfiguration.new(name: :tcp_example)
service_config.add_handler(TcpSumExample.new)

server = MicroRb::Servers::TCP.new(service_config)
server.start!
