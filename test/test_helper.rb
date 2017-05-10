# coding: utf-8
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require File.expand_path(File.dirname(__FILE__) + '/../lib/micro-rb')
require 'minitest/autorun'
require 'minitest/reporters'
require 'shoulda'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new(color: true)
ENV['MICRO_ENV'] ||= 'test'
