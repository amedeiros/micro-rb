# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: sum.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message 'micro_rb.sum_handler.Request' do
    optional :a, :int32, 1
    optional :b, :int32, 2
  end
  add_message 'micro_rb.sum_handler.Response' do
    optional :total, :int32, 1
  end
end

module MicroRb
  module SumHandler
    Request  = Google::Protobuf::DescriptorPool.generated_pool.lookup('micro_rb.sum_handler.Request').msgclass
    Response = Google::Protobuf::DescriptorPool.generated_pool.lookup('micro_rb.sum_handler.Response').msgclass
  end
end
