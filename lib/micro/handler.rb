# coding: utf-8

module MicroRb
  module Handler
    extend ActiveSupport::Concern

    included do
      include SemanticLogger::Loggable

      def self.handler(options)
        raise 'Missing name' unless options.key?(:name)
        raise 'Metadata should be a Hash' if options.key?(:metadata) && !options.is_a?(Hash)

        class_attribute :name
        public_send('name=', options[:name])

        class_attribute :metadata
        public_send('metadata=', options[:metadata] || {})
      end

      def rpc_methods
        self.methods - Object.methods - non_rpc_methods
      end

      def request_structure
        build_structure(self.class::Request)
      end

      def response_structure
        build_structure(self.class::Response)
      end

      private

      def non_rpc_methods
        [:name=, :name, :name?, :logger, :logger=,
         :rpc_methods, :request_structure, :response_structure,
         :metadata, :metadata=, :metadata?]
      end

      def build_structure(type)
        structure_values = []

        type.descriptor.entries.each do |descriptor|
          structure_values << { name: descriptor.name, type: descriptor.type }
        end

        { values: structure_values }
      end
    end
  end
end
