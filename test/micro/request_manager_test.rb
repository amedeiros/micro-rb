# coding: utf-8
# frozen_string_literal: true

require 'test_helper'

class RequestManagerTest < Minitest::Test
  context 'RequestManager' do
    setup { @request_manager = MicroRb::RequestManager.new }

    context 'required keys' do
      should 'fail for missing required key :method' do
        response = decode(@request_manager.handle_request(encode({ service: 'test' })))

        assert_equal -32600, response[:error][:code]
        assert_equal 'The JSON sent is not a valid Request object.', response[:error][:message]
      end
    end

    context 'required types' do
      should 'fail for wrong :method key type' do
        response = decode(@request_manager.handle_request(encode({ method: { service: 1 }, params: {}, id: 1 })))

        assert_equal -32600, response[:error][:code]
        assert_equal 'The JSON sent is not a valid Request object.', response[:error][:message]
      end

      should 'fail for wrong params type' do
        response = decode(@request_manager.handle_request(encode({ method: 'sum', params: 1, id: 1})))

        assert_equal -32600, response[:error][:code]
        assert_equal 'The JSON sent is not a valid Request object.', response[:error][:message]
      end

      should 'fail for wrong id type' do
        response = decode(@request_manager.handle_request(encode({ method: 'sum', params: {}, id: {}})))

        assert_equal -32600, response[:error][:code]
        assert_equal 'The JSON sent is not a valid Request object.', response[:error][:message]
      end
    end

    context 'parse error' do
      should 'fail for a parse error' do
        response = decode(@request_manager.handle_request('{"a: 1}'))

        assert_equal -32700, response[:error][:code]
        assert_equal 'Invalid JSON was received by the server. An error occurred on the server while parsing the JSON text.', response[:error][:message]
      end
    end

    context 'internal error' do
      should 'fail for an internal error' do
        @request_manager.expects(:decode).raises(StandardError.new('Something went wrong'))
        response = decode(@request_manager.handle_request(encode({ method: 'sum', params: {}, id: 1})))

        assert_equal -32603, response[:error][:code]
        assert_equal 'Internal server error: Something went wrong', response[:error][:message]
      end
    end

    context 'method not found' do
      should 'fail for a missing rpc method' do
        response = decode(@request_manager.handle_request(encode({ method: 'sum', params: [{ a: 1, b: 1 }], id: 1})))

        assert_equal -32601, response[:error][:code]
        assert_equal "Method 'sum' not found.", response[:error][:message]
      end
    end
  end

  private

  def decode(json)
    MultiJson.decode(json).with_indifferent_access
  end

  def encode(hash)
    MultiJson.encode(hash)
  end
end
