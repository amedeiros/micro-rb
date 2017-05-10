require 'test_helper'
require 'google/protobuf'

class HandlerTest < Minitest::Test
  context '#name' do
    should 'have a name' do
      assert_equal :test_handler, TestHandler.new.name
    end
  end

  context '#metadata' do
    should 'have metadata' do
      assert_equal({ about: 'respond with a hello message!' }, TestHandler.new.metadata)
    end
  end

  context '#rpc_method' do
    should 'have a rpc method' do
      assert_equal :hello, TestHandler.new.rpc_method
    end
  end

  context 'valid?' do
    context 'valid' do
      should 'be valid for having a Request, Response, name and rpc_method' do
        assert TestHandler.new.valid?
      end
    end

    context 'invalid' do
      setup { @handler = TestHandler.new }

      should 'be invalid for a missing name' do
        @handler.name = nil

        refute @handler.valid?
      end

      should 'be invalid for a missing rpc_method' do
        @handler.rpc_method = nil

        refute @handler.valid?
      end
    end
  end

  context '#full_rpc_name' do
    should 'have a correct full rpc name for the handler' do
      assert_equal 'TestHandler.hello', TestHandler.new.full_rpc_name
    end
  end

  context '#response_structure' do
    should 'have the correct response structure' do
      structure = TestHandler.new.response_structure

      assert structure.key?(:values)
      assert structure[:values].first.key?(:name)
      assert structure[:values].first.key?(:type)
      assert_equal :string, structure[:values].first[:type]
      assert_equal 'msg', structure[:values].first[:name]
    end
  end

  context '#request_structure' do
    should 'have the correct request structure' do
      structure = TestHandler.new.request_structure

      assert structure.key?(:values)
      assert structure[:values].first.key?(:name)
      assert structure[:values].first.key?(:type)
      assert_equal :string, structure[:values].first[:type]
      assert_equal 'name', structure[:values].first[:name]
    end
  end
end

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
