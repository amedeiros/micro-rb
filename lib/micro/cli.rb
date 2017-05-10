# coding: utf-8
# frozen_string_literal: true

require 'optparse'
require 'micro/project_generator'

module MicroRb
  class CLI
    attr_reader :parser, :options

    def initialize(argv)
      setup
      @options = {}
      parser.parse! argv.dup
    end

    def run!
      if options.empty?
        puts parser
        exit
      end

      generate_new if options.key?(:new)
    end

    private

    def setup
      @parser = OptionParser.new do |opts|
        opts.banner = 'microrb <options>'

        opts.on '-n', '--new NAME', 'Generate a new skeleton service.' do |name|
          options[:new] = name
        end

        opts.on '-e', '--encryption', 'Adds Symmetric Encryption gem to your new service.' do |encryption|
          options[:encryption] = encryption
        end

        opts.on '-a', '--activerecord', 'Adds ActiveRecord to your gemfile and a default DB setup.' do |ar|
          options[:active_record] = ar
        end

        opts.on '-h', '--help', 'Display this help screen' do
          puts opts
          exit
        end
      end
    end

    def generate_new
      puts "Generating new service called #{options[:new]}..."
      active_record = options[:active_record]
      encryption    = options[:encryption]
      name          = options[:new]

      ProjectGenerator.new(name, encryption, active_record).create!

      puts 'Complete...'
      if options[:encryption]
        puts 'Please see https://rocketjob.github.io/symmetric-encryption/standalone.html'\
' for setting up SymmetricEncryption'
      end
      puts 'Run sidecar: micro sidecar'
      puts 'Run micro web: micro --web_address 0.0.0.0:8080 web'
      puts "Run me:  ./#{name}/bin/#{name}"
    end
  end
end
