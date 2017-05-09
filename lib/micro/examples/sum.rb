require 'microrb'
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

server = MicroRb::Servers::Web.new(:test, debug: true, metadata: { example: 'Service' })
server.add_handler MyHandler.new
server.start!
