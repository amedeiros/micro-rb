# coding: utf-8
# frozen_string_literal: true

require 'test_helper'

class ConfigurationTest < Minitest::Test
  context 'MicroRb::Configuration' do
    context 'defaults' do
      context 'sidecar' do
        should 'have a default port' do
          assert_equal '8081', MicroRb::Configuration.instance.sidecar_port
        end

        should 'have a default host' do
          assert_equal 'http://127.0.0.1', MicroRb::Configuration.instance.sidecar_host
        end

        should 'have a default registry' do
          assert_equal '/registry', MicroRb::Configuration.instance.sidecar_registry
        end
      end

      context 'gateway' do
        should 'have a default port' do
          assert_equal '3002', MicroRb::Configuration.instance.gateway_port
        end

        should 'have a default host' do
          assert_equal 'http://127.0.0.1', MicroRb::Configuration.instance.gateway_host
        end

        should 'have a default rpc endpoint' do
          assert_equal '/rpc', MicroRb::Configuration.instance.gateway_rpc
        end
      end
    end

    context '.configure' do
      teardown do
        # Reset defaults so the default tests dont fail
        MicroRb::Configuration.configure do |c|
          host = 'http://127.0.0.1'
          c.sidecar_port = '8081'
          c.sidecar_host = host
          c.sidecar_registry = '/registry'

          c.gateway_host = host
          c.gateway_port = '3002'
          c.gateway_rpc  = '/rpc'
        end
      end

      context 'sidecar' do
        should 'change the default port' do
          port = '8080'
          MicroRb::Configuration.configure { |c| c.sidecar_port = port }

          assert_equal port, MicroRb::Configuration.instance.sidecar_port
        end

        should 'change the default host' do
          host = 'http://myhost.com'
          MicroRb::Configuration.configure { |c| c.sidecar_host = host }

          assert_equal host, MicroRb::Configuration.instance.sidecar_host
        end

        should 'change the default registry endpoint' do
          registry = '/something_else'
          MicroRb::Configuration.configure { |c| c.sidecar_registry = registry }

          assert_equal registry, MicroRb::Configuration.instance.sidecar_registry
        end
      end

      context 'gateway' do
        should 'change the default port' do
          port = '8080'
          MicroRb::Configuration.configure { |c| c.gateway_port = port }

          assert_equal port, MicroRb::Configuration.instance.gateway_port
        end

        should 'change the default host' do
          host = 'http://myhost.com'
          MicroRb::Configuration.configure { |c| c.gateway_host = host }

          assert_equal host, MicroRb::Configuration.instance.gateway_host
        end

        should 'change the default rpc endpoint' do
          rpc = '/something_else'
          MicroRb::Configuration.configure { |c| c.gateway_rpc = rpc }

          assert_equal rpc, MicroRb::Configuration.instance.gateway_rpc
        end
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
