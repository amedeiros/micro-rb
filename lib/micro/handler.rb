# coding: utf-8

module MicroRb
  module Handler
    extend ActiveSupport::Concern

    included do
      include SemanticLogger::Loggable

      def self.handler(options)
        raise 'Missing name' unless options.key?(:name)

        class_attribute :name
        public_send('name=', options[:name])
      end

      def rpc_methods
        self.methods - Object.methods - non_rpc_methods
      end

      def request_structure
        request_values  = []

        self.class::Request.descriptor.entries.each do |descriptor|
          request_values << { name: descriptor.name, type: descriptor.type }
        end

        { values: request_values }
      end

      def response_structure
        response_values  = []

        self.class::Response.descriptor.entries.each do |descriptor|
          response_values << { name: descriptor.name, type: descriptor.type }
        end

        { values: response_values }
      end

      private

      def non_rpc_methods
        [:name=, :name, :name?, :logger, :logger=, :rpc_methods, :request_structure, :response_structure]
      end
    end
  end
end
