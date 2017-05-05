# coding: utf-8

require 'optparse'
require_relative 'project_generator'

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

        opts.on '-h', '--help', 'Display this help screen' do
          puts opts
          exit
        end
      end
    end

    def generate_new
      puts "Generating new service called #{options[:new]}..."
      name = options[:new]

      ProjectGenerator.new(name).create!

      puts 'Complete...'
      puts 'Run sidecar: micro sidecar'
      puts 'Run micro web: micro --web_address 0.0.0.0:8080 web'
      puts "Run me:  ./#{name}/bin/#{name}"
    end
  end
end