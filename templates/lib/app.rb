# Load Bundler and load all your gems
require 'bundler/setup'

# Explicitly load any gems you need.
require 'micro/microrb'
require '<%= @name %>/version'
require '<%= @name %>/handlers/example_handler'

module <%= @class_name %>
  # Your code goes here...
  # Good place for your main application logic if this is a library.

  # be sure to create unit tests for them too.
end
