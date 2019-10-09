# SchwadPerformanceLogger

This gem allows you to track memory usage and time passage during the life of
the SchwadPerformanceLogger object, as well as deltas between each check. The output
is `puts`'d to the console, and it also writes to a long-running CSV and per-object
log file in `logs/schwad_performance_logger`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'schwad_performance_logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install schwad_performance_logger

## Usage

`pl = SchwadPerformanceLogger.new({full_memo: 'Check extract method refactoring'})`

```
**********************************************************************
Starting initialization. Current memory: 12(Mb), difference of 0 (mb) since beginning and difference of 0 since last log. time passed: 0.004678 seconds, time since last run: 0.004678
**********************************************************************
```

Each subsequent log:

`pl.log_performance("Test memo")`

```
*********************************************************************
Starting Test memo. Current memory: 12(Mb), difference of 0 (mb) since beginning and difference of 0 since last log. time passed: 22.493993 seconds, time since last run: 9.616874
*********************************************************************
```

### Options

`full_memo` option adds an extra header in the `log` outputs as well as a header to each new set of csv outputs. This is not to be confused with the 'per-run' message passed to `#log_performance` which is only passed to that check.

To disable any of the outputs:

`SchwadPerformanceLogger.new({puts: false, log: false, csv: false})`

To have the logger 'pause' a number of seconds during the `puts` logging so that
you can actually see the log as it goes by. This does not affect the 'time' measurement:

`SchwadPerformanceLogger.new({pause: 8})`

## Usage example:

```
pl = SchwadPerformanceLogger.new({pause: 3, full_memo: 'Retry object-oriented approach.', log: false})
pl.log_performance('check status before writing to database')

# code here

pl.log_performance('check status after writing to database')

# code

pl.log_performance('inspect final performance after executing service')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/schwad_performance_logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SchwadPerformanceLogger project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/schwad_performance_logger/blob/master/CODE_OF_CONDUCT.md).
