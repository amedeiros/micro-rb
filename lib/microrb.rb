# coding: utf-8

require 'active_support/all'
require 'semantic_logger'

module MicroRb
  include SemanticLogger::Loggable

  def self.env
    ActiveSupport::StringInquirer.new(ENV['MICRO_ENV'] || 'development')
  end
end

require 'bundler/setup'
Bundler.require(:default, MicroRb.env)

require 'micro/version'
require 'micro/configuration'
require 'micro/sidecar/base'
require 'micro/sidecar/register'
require 'micro/sidecar/call'
require 'micro/handler'
require 'micro/handler_manager'
require 'micro/servers/web'
require 'micro/servers/error'
