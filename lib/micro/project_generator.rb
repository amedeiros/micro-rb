# coding: utf-8

require 'active_support/core_ext/string/inflections'
require 'fileutils'
require 'erb'

module MicroRb
  class ProjectGenerator
    attr_reader :name, :class_name, :username,
                :year, :encryption, :active_record, :engine

    def initialize(name, encryption, active_record)
      @active_record = active_record
      @class_name    = name.classify
      @encryption    = encryption
      @username      = ENV['USERNAME'] || ENV['USER']
      @name          = name
      @year          = Time.new.year
      @engine        = RUBY_ENGINE == 'jruby' ? 'activerecord-jdbcmysql-adapter' : 'mysql2'
    end

    def create!
      template_path = File.expand_path('../../../templates', __FILE__)

      FileUtils.cp_r(template_path, name)

      FileUtils.mv File.join(name, 'lib', 'app'), File.join(name, 'lib', name)
      FileUtils.mv File.join(name, 'lib', 'app.rb'), File.join(name, 'lib', "#{name}.rb")
      FileUtils.mv File.join(name, 'test', 'app_test.rb'),
                   File.join(name, 'test', "#{name}_test.rb")
      FileUtils.mv File.join(name, 'bin', 'app'), File.join(name, 'bin', name)

      FileUtils.chmod 'u=wrx', File.join(name, 'bin', name)

      [
          File.join(name, 'bin', name),
          File.join(name, 'lib', "#{name}.rb"),
          File.join(name, 'lib', name, 'version.rb'),
          File.join(name, 'lib', name, 'handlers', 'example_handler.rb'),
          File.join(name, 'test', "#{name}_test.rb"),
          File.join(name, 'README.md'),
          File.join(name, 'LICENSE'),
          File.join(name, 'Gemfile')
      ].each { |file| render_template(file, binding) }

      install
    end

    private

    def install
      Dir.chdir(name) do
        Bundler.with_clean_env do
          system('bundle')
        end
      end
    end

    def render_template(template, context)
      t = File.read(template)

      File.open(template, 'w') do |f|
        f << ERB.new(t, nil, '-').result(context)
      end
    end
  end
end
