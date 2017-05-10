# coding: utf-8
# frozen_string_literal: true

require 'test_helper'

class ConfigurationTest < Minitest::Test
  context 'MicroRb::Configuration' do
    context 'defaults' do
      should 'have a default sidecar port' do
        assert_equal '8081', MicroRb::Configuration.instance.sidecar_port
      end

      should 'have a default sidecar host' do
        assert_equal 'http://127.0.0.1', MicroRb::Configuration.instance.sidecar_host
      end

      should 'have a default sidecar registry' do
        assert_equal '/registry', MicroRb::Configuration.instance.sidecar_registry
      end
    end

    context '.configure' do
      teardown do
        # Reset defaults so the default tests dont fail
        MicroRb::Configuration.configure do |c|
          c.sidecar_port = '8081'
          c.sidecar_host = 'http://127.0.0.1'
          c.sidecar_registry = '/registry'
        end
      end

      should 'change the default sidecar port' do
        port = '8080'
        MicroRb::Configuration.configure { |c| c.sidecar_port = port }

        assert_equal port, MicroRb::Configuration.instance.sidecar_port
      end

      should 'change the default sidecar host' do
        host = 'http://myhost.com'
        MicroRb::Configuration.configure { |c| c.sidecar_host = host }

        assert_equal host, MicroRb::Configuration.instance.sidecar_host
      end

      should 'change the default sidecar registry' do
        registry = '/something_else'
        MicroRb::Configuration.configure { |c| c.sidecar_registry = registry }

        assert_equal registry, MicroRb::Configuration.instance.sidecar_registry
      end
    end

    context '#sidecar_uri' do
      should 'have the correct sidecar uri' do
        assert_equal 'http://127.0.0.1:8081', MicroRb::Configuration.instance.sidecar_uri
      end
    end

    context '#sidecar_registry_uri' do
      should 'have the correct sidecar registry uri' do
        assert_equal 'http://127.0.0.1:8081/registry', MicroRb::Configuration.instance.sidecar_registry_uri
      end
    end
  end
end
