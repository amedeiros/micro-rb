require_relative '../microrb'

class Myhandler
  include MicroRb::Handler
  handler name: :test

  def sum(request, params)
    { total: params['a'] + params['b'] }
  end
end

server = MicroRb::Servers::Web.new(:test, debug: true)
server.add_handler Myhandler.new
server.start!
