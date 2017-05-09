require 'microrb'
require_relative '../examples/proto/sum_pb'

class MyHandler
  include MicroRb::Handler
  include MicroRb::SumHandler

  handler name: :test, metadata: { hello: 'Micro-Rb' }

  def sum(request: Request, response: Response)
    response.total = request.a + request.b

    response
  end
end

server = MicroRb::Servers::Web.new(:test, debug: true, metadata: { example: 'Service' })
server.add_handler MyHandler.new
server.start!
