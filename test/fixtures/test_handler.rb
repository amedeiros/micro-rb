require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message 'micro_rb.test_handler.Request' do
    optional :name, :string, 1
  end
  add_message 'micro_rb.test_handler.Response' do
    optional :msg, :string, 1
  end
end

module MicroRb
  module TestHandler
    Request  = Google::Protobuf::DescriptorPool.generated_pool.lookup('micro_rb.test_handler.Request').msgclass
    Response = Google::Protobuf::DescriptorPool.generated_pool.lookup('micro_rb.test_handler.Response').msgclass
  end
end

class TestHandler
  include MicroRb::TestHandler
  include MicroRb::Handler

  handler name: :test_handler, rpc_method: :hello,
          metadata: { about: 'respond with a hello message!' }

  def hello(request: Request.new, response: Response.new)
    response.msg = "Hello, #{request.name}"

    response
  end
end