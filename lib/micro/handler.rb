# coding: utf-8

module MicroRb
  module Handler
    extend ActiveSupport::Concern

    included do
      include SemanticLogger::Loggable

      def self.handler(options)
        fail 'Missing name' unless options.key?(:name)

        class_attribute :name
        public_send('name=', options[:name])
      end
    end
  end
end