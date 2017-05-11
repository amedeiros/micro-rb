# coding: utf-8
# frozen_string_literal: true

require 'test_helper'
require 'fixtures/test_handler'

class HandlerManagerTest < Minitest::Test
  context 'MicroRb::HandlerManager' do
    setup { @handler_manager = MicroRb::HandlerManager.new }

    context '#add_handler' do
      should 'add a valid handler' do
        @handler_manager.add_handler(TestHandler.new)

        assert_equal 1, @handler_manager.handlers.size
      end

      should 'raise an exception for not being of type MicroRb::Handler' do
        error = assert_raises StandardError do
          @handler_manager.add_handler([])
        end

        assert_equal 'Handler must be of type MicroRb::Handler got Array', error.message
      end

      should 'raise an exception for an already registered handler' do
        test_handler = TestHandler.new
        @handler_manager.add_handler(test_handler)

        error = assert_raises StandardError do
          @handler_manager.add_handler(test_handler)
        end

        assert_equal "Handler #{test_handler.name} has already been registered.", error.message
      end

      should 'raise an exception for an invalid handler' do
        test_handler = TestHandler.new
        test_handler.rpc_method = nil

        error = assert_raises StandardError do
          @handler_manager.add_handler(test_handler)
        end

        assert_equal "Handler #{test_handler.name} is invalid.", error.message
      end
    end

    context '#endpoints' do
      should 'have the correct endpoints' do
        test_handler = TestHandler.new
        @handler_manager.add_handler(test_handler)
        endpoint = @handler_manager.endpoints.first

        assert_equal test_handler.full_rpc_name, endpoint[:name]
        assert_equal test_handler.request_structure, endpoint[:request]
        assert_equal test_handler.response_structure, endpoint[:response]
        assert_equal test_handler.metadata, endpoint[:metadata]
      end
    end

    context '#rpc_method' do
      should 'return the correct rpc method' do
        test_handler = TestHandler.new
        @handler_manager.add_handler(test_handler)
        rpc_method = @handler_manager.rpc_method(test_handler.full_rpc_name)

        assert_equal test_handler.rpc_method, rpc_method.name
      end
    end

    context '#rpc_method?' do
      should 'return false for a missing rpc method' do
        refute @handler_manager.rpc_method?(:fake)
      end

      should 'return true for a present rpc method' do
        test_handler = TestHandler.new
        @handler_manager.add_handler(test_handler)

        assert @handler_manager.rpc_method?(test_handler.full_rpc_name)
      end
    end

    context '#rpc_method_response' do
      should 'return the handlers response type' do
        test_handler = TestHandler.new
        @handler_manager.add_handler(test_handler)

        assert_equal TestHandler::Response.new, @handler_manager.rpc_method_response(test_handler.full_rpc_name)
      end
    end

    context '#rpc_method_requst' do
      should 'return the handlers request type' do
        test_handler = TestHandler.new
        @handler_manager.add_handler(test_handler)

        assert_equal TestHandler::Request.new, @handler_manager.rpc_method_request(test_handler.full_rpc_name, {})
      end
    end

    context '#call_rpc_method' do
      should 'call the correct rpc method' do
        handler = TestHandler.new
        name    = 'Micro-rb'
        expect  = "Hello, #{name}"
        params  = [{name: name}]
        @handler_manager.add_handler(handler)

        assert_equal expect, @handler_manager.call_rpc_method(handler.full_rpc_name, params).msg
      end
    end
  end
end
