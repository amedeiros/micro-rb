# coding: utf-8

module MicroRb
  module Handler
    extend ActiveSupport::Concern

    included do
      include SemanticLogger::Loggable

      def self.handler(options)
        raise 'Missing name' unless options.key?(:name)
        raise 'Missing rpc_method' unless options.key?(:rpc_method)
        raise 'Metadata should be a Hash' if options.key?(:metadata) && !options.is_a?(Hash)

        class_attribute :name
        public_send('name=', options[:name])

        class_attribute :metadata
        public_send('metadata=', options[:metadata] || {})

        class_attribute :rpc_method
        public_send('rpc_method=', options[:rpc_method].to_sym)
      end

      def full_rpc_name
        "#{self.class.to_s.split('::').last}.#{rpc_method}"
      end

      def request_structure
        build_structure(self.class::Request)
      end

      def response_structure
        build_structure(self.class::Response)
      end

      def valid?
        self.class.constants.include?(:Request) &&
            self.class.constants.include?(:Response) &&
            name.present? &&
            rpc_method.present?
      end

      private

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
