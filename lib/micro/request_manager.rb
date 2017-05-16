# coding: utf-8
# frozen_string_literal: true

module MicroRb
  class RequestManager
    attr_reader :handler_manager

    REQUIRED_TYPES = { method: [String], params: [Hash, Array],
                       id: [String, Integer, NilClass] }.freeze

    REQUIRED_KEYS  = ['method'].freeze

    def initialize(handler_manager = MicroRb::HandlerManager.new)
      @handler_manager = handler_manager
    end

    def handle_request(request)
      response = nil

      begin
        request  = decode(request)
        response = create_response(request) if valid_request?(request)
        response ||= error_response(MicroRb::Servers::Error::InvalidRequest.new, request)
      rescue MultiJson::ParseError => e
        MicroRb.logger.warn(e)
        response = error_response(MicroRb::Servers::Error::ParseError.new)
      rescue StandardError => e
        MicroRb.logger.warn(e)
        response = error_response(MicroRb::Servers::Error::InternalError.new(e), request)
      end

      MultiJson.encode(response)
    end

    private

    def create_response(request)
      method = request[:method].strip.to_sym
      params = request[:params].map(&:symbolize_keys) if request[:params].is_a?(Array)
      params ||= request[:params].symbolize_keys

      unless handler_manager.rpc_method?(method)
        return error_response(MicroRb::Servers::Error::MethodNotFound.new(method), request)
      end

      response = handler_manager.call_rpc_method(method, params)

      success_response(request, response)
    end

    def valid_request?(request)
      return false unless request.is_a?(Hash)

      REQUIRED_KEYS.each do |key|
        return false unless request.key?(key)
      end

      REQUIRED_TYPES.each do |key, types|
        return false if request.key?(key) &&
                        types.none? { |type| request[key].is_a?(type) }
      end

      true
    end

    def success_response(request, result)
      { result: result, id: request['id'] }
    end

    def error_response(error, request = {})
      { error: error.to_h, id: request['id'] }
    end

    def decode(request)
      MultiJson.decode(request).with_indifferent_access
    end
  end
end
