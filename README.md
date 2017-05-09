# MicroRb

MicroRb allows you to develop micro services for the [micro](https://github.com/micro/micro) framework.
MicroRb uses the [sidecar](https://github.com/micro/micro/tree/master/car) that comes with micro. If you want to write services in Go see [go-micro](https://github.com/micro/go-micro) or in java see [ja-micro](https://github.com/Sixt/ja-micro). 

## Installation

Currently not on rubygems install with bundler and git

```ruby
gem 'micro-rb', github: 'amedeiros/micro-rb'
````

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

## Google Protobufs

Currently supporting protobufs where each handler includes the module generated with requiring a Response and Request type. The example below is for the sum handler. 

`$ protoc --ruby_out=. sum.proto`


```proto
syntax = "proto3";

package micro_rb.sum_handler;

service Sum {
    rpc Sum(Request) returns (Response) { }
}

message Request {
    int32 a = 1;
    int32 b = 2;
}

message Response {
    int32 total = 1;
}

```

## Usage

```ruby
require 'microrb'
require_relative '../examples/proto/sum_pb'

class MyHandler
  include MicroRb::Handler
  include MicroRb::SumHandler

  handler name: :test

  def sum(request: Request, response: Response)
    response.total = request.a + request.b

    response
  end
end

server = MicroRb::Servers::Web.new(:test, debug: true)
server.add_handler MyHandler.new
server.start!

```

Configuration has the following defaults for sidecar endpoint.

`Host: "http://127.0.0.1"`

`Port: 8081`

`Registy: "/registry"`


Configuration can be changed.

```ruby
MicroRb::Configuration.configure do |c|
  c.sidecar_host     = 'http://mysite.com'
  c.sidecar_port     = '8080'
  c.sidecar_registry = '/awesome_registry'
end
```

Want to run puma? No problem just add puma to your Gemfile and require the rack handler and tell the web server to use puma.
This works with thin etc because we just pass the options along to the rack server. Try it with the sum example!

```ruby
require 'rack/handler/puma'
server = MicroRb::Servers::Web.new(:test, debug: true, server: :puma)
```


![alt text](https://github.com/amedeiros/micro-rb/blob/master/registry.png)
![alt text](https://github.com/amedeiros/micro-rb/blob/master/sum.png)


## Micro API Gateway

`micro api --address 0.0.0.0:3002`

```
$ http POST 0.0.0.0:3002/rpc method=sum service=test request='{"a": 1, "b": 2}'
HTTP/1.1 200 OK
Access-Control-Allow-Credentials: true
Access-Control-Allow-Headers: Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization
Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE
Content-Length: 11
Content-Type: application/json
Date: Tue, 09 May 2017 17:50:47 GMT

{
    "total": 3
}
```

## Calling the service directly

```
$ http POST 0.0.0.0:3000 service=test method=sum id=1 params:='[{"a": 1, "b": 2}]'
HTTP/1.1 200 OK
Connection: Keep-Alive
Content-Length: 31
Date: Tue, 09 May 2017 18:08:25 GMT
Server: WEBrick/1.3.1 (Ruby/2.4.0/2016-12-24)

{"result":{"total":3},"id":"1"}
```

## Project Generator

```
microrb <options>
    -n, --new NAME                   Generate a new skeleton service.
    -e, --encryption                 Adds Symmetric Encryption gem to your new service.
    -a, --activerecord               Adds ActiveRecord to your gemfile and a default DB setup.
    -h, --help                       Display this help screen
```


To generate a new micro service project run the following. Note this also adds [Symmetric Encryption](https://github.com/rocketjob/symmetric-encryption) gem with the -e flag.

`microrb -n myservice -e`

This will output a new project with the example sum service ready to run.

```
Generating new service called myservice...
Fetching gem metadata from https://rubygems.org/.............
Fetching version metadata from https://rubygems.org/.
Resolving dependencies...
...... More bundler stuff here
Complete...
Please see https://rocketjob.github.io/symmetric-encryption/standalone.html for setting up SymmetricEncryption
Run sidecar: micro sidecar
Run micro web: micro --web_address 0.0.0.0:8080 web
Run me:  ./myservice/bin/myservice
```

```
./myservice/bin/myservice
[2017-05-05 14:28:52] INFO  WEBrick 1.3.1
[2017-05-05 14:28:52] INFO  ruby 2.3.1 (2017-03-06) [java]
[2017-05-05 14:28:52] INFO  WEBrick::HTTPServer#start: pid=48485 port=3000
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amedeiros/micro-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

