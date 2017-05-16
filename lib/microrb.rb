# coding: utf-8
# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'
require 'semantic_logger'
require 'multi_json'

module MicroRb
  include SemanticLogger::Loggable

  def self.env
    ActiveSupport::StringInquirer.new(ENV['MICRO_ENV'] || 'development')
  end
end

require 'micro/version'
require 'micro/configuration'
require 'micro/service_configuration'
require 'micro/clients/base'
require 'micro/clients/sidecar'
require 'micro/clients/rpc'
require 'micro/clients/http'
require 'micro/clients/tcp'
require 'micro/handler'
require 'micro/handler_manager'
require 'micro/request_manager'
require 'micro/servers/web'
require 'micro/servers/error'
require 'micro/servers/tcp'
require 'micro/handlers/debug'
