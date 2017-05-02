# MicroRb

MicroRb allows you to developer micro services for the [micro](https://github.com/micro/micro) framework.
MicroRb uses the [sidecar](https://github.com/micro/micro/tree/master/car) that comes with micro. If you want to write services in Go see [go-micro](https://github.com/micro/go-micro) or in java see [ja-micro](https://github.com/Sixt/ja-micro). 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'micro-rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install micro-rb

## Status

Currently in development. If I can get some pull requests that would be much appreciated.

## Usage

```ruby
class Myhandler
  include MicroRb::Handler
  handler name: :test

  def sum(request, params)
    { total: params['a'] + params['b'] }
  end
end


server = MicroRb::Servers::Web.new(:test, debug: true)
server.add_handler Myhandler.new
server.start!
```

Configuration has the following defaults for sidecar endpoint.

`Host: "http://127.0.0.1:8081"`

`Registy: "/registry"`


Configuration can be changed.

```ruby
MicroRb::Configuration.configure do |c|
  c.sidecar_host     = 'http://mysite.com:8080'
  c.sidecar_registry = '/awesome_registry'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amedeiros/micro-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

