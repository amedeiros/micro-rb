# coding: utf-8
# frozen_string_literal: true

# Your tests should require this file which sets up the test harness.
require 'minitest/autorun'
require 'minitest/reporters'

reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]
