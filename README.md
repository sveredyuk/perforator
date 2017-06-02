https://travis-ci.org/sveredyuk/perforator.svg?branch=master

# Perforator

### Simple and pretty stupid way to measure execution time of your code

Quick example
```ruby
meter = Perforator::Meter.new(puts: true)

meter.call do
  sleep 1 # doing some serious job
end

# =======>
# Start: 2017-06-02 14:24:53 +0300
# Finish: 2017-06-02 14:24:54 +0300
# Spent: 1.000919
```

More details below

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'perforator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install perforator

## Usage

### Options
You can init new meter object with following arguments:

```ruby
my_meter = Perforator::Meter.new(
  name: 'your label', # -> meter name, just label for passing in start line # =======> your label
  logger: Logger.new('my_logger.log'), # -> logger object, will receive :info at each step
  puts: true, # -> true/false output to STDOUT
  expected_time: 10, # -> time in seconds (!) that expected for execution
  positive_callback: proc { puts ':)' }, # -> executed if real execution less than expected
  negative_callback: proc { puts ':(' } # -> executed if real execution more than expected
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sveredyuk/perforator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

