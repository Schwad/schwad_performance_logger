# SchwadPerformanceLogger

This gem allows you to track memory usage and time passage in your code. It does this during the life of
the SPL object, as well as giving deltas between each check. The output
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

`pl = SPL.new({full_memo: 'Check extract method refactoring'})`

```
********************************************************************************
initialization
Current memory:          42 Mb
Difference since start:  0 Mb
Difference since last log: 0 Mb
Time passed:             0.018000000000000002 milliseconds
Time since last run:     0.018000000000000002 milliseconds
********************************************************************************
```

Each subsequent log:

`pl.log_performance("Test memo")`

```
********************************************************************************
Test memo
Current memory:          42 Mb
Difference since start:  0 Mb
Difference since last log: 0 Mb
Time passed:             0.283 milliseconds
Time since last run:     0.265 milliseconds
********************************************************************************
```

### Options

`full_memo` option adds an extra header in the `log` outputs as well as a header to each new set of csv outputs. This is not to be confused with the 'per-run' message passed to `#log_performance` which is only passed to that check.

To disable any of the outputs:

`SPL.new({puts: false, log: false, csv: false})`

To have the logger 'pause' a number of seconds during the `puts` logging so that
you can actually see the log as it goes by. This does not affect the 'time' measurement:

`SPL.new({pause: 8})`

You can also use `#log_performance` under alias `#lp`

## Usage example:

```
pl = SPL.new({pause: 3, full_memo: 'Retry object-oriented approach.', log: false})
pl.log_performance('check status before writing to database')

# code here

pl.log_performance('check status after writing to database')

# code

pl.log_performance('inspect final performance after executing service')
```

## Block syntax

You may also pass a block to `#log_performance`

```ruby
pl.log_performance("check this chonk of code") do
ary = []
12345.times do |i|
  ary << i
end
```

## Further Profiling Tools

As well as logging memory and time throughout your code, SPL gives you easy access to frequently used popular profiling tools to inspect your code blocks.

### IPS

Handy access to [Benchmark-ips](https://github.com/evanphx/benchmark-ips) measurements, just pass a block to ips:

```ruby
SPL.ips do
   ary = []
   35.times do
     ary << (1..99).to_a.sample
   end
end

#=> #<Benchmark::IPS::Report:0x00007fbc7f91df50 @entries=[#<Benchmark::IPS::Report::Entry:0x00007fbc7e0c3bd0 @label="PerformanceLogMethod", @microseconds=5002798.0, @iterations=34020, @stats=#<Benchmark::IPS::Stats::SD:0x00007fbc7e0c3c48 @mean=6805.780564500376, @error=195>, @measurement_cycle=630, @show_total_time=true>], @data=nil>
```

### Time

Same flow as above. Tired of writing out `start_time` and `Time.now - start_time` and also needing to 'puts' it out? Pass a block to `#time`. Runs ten times and spits out an average as well.

```ruby
SPL.time do
   ary = []
   35.times do
     ary << (1..99).to_a.sample
   end
end

#=> Average runtime 0.0002649 seconds. Max time 0.000508.seconds
```

### Allocate Count

Before, you would have to enable the `GC` before your code, use `ObjectSpace` to count objects before your code, then use it again after your code to compare allocated objects during your block of code. You'd also have to re-enable the `GC`! Gosh, that sure is a lot of work if you want to do this frequently. We make it simple.

```ruby
SPL.allocate_count do
   ary = []
   35.times do
     ary << (1..99).to_a.sample
   end
end

#=> {:FREE=>-121, :T_STRING=>50, :T_ARRAY=>36, :T_IMEMO=>35}
```

### Profile Memory

Gives you quick access to the amazing [memory_profiler](https://github.com/SamSaffron/memory_profiler) gem.

```ruby
SPL.profile_memory do
   ary = []
   35.times do
     ary << (1..99).to_a.sample
   end
end

# Total allocated: 37576 bytes (36 objects)
# Total retained:  0 bytes (0 objects)
#
# allocated memory by gem
# -----------------------------------
#      37576  other
#
# allocated memory by file
# -----------------------------------
#      37576  (irb)
#
# allocated memory by location
# -----------------------------------
#      37240  (irb):37
#        336  (irb):35
#
# allocated memory by class
# -----------------------------------
#      37576  Array
#
# allocated objects by gem
# -----------------------------------
#         36  other
#
# allocated objects by file
# -----------------------------------
#         36  (irb)
#
# allocated objects by location
# -----------------------------------
#         35  (irb):37
#          1  (irb):35
#
# allocated objects by class
# -----------------------------------
#         36  Array
```

### All Objects

Similarly, it's nice to get a rundown of all objects, in hash format, instead of goofing around with `ObjectSpace` manually we offer that up for you as well.

```ruby
SPL.all_objects do
  ary = []
  35.times do
    ary << (1..99).to_a.sample
  end
end

#=> [[Benchmark::IPS::Job, 1], [Rational, 1], [Benchmark::IPS::Report::Entry, 1], [Benchmark::IPS::Stats::SD, 1], [FFI::DynamicLibrary, 1], [DidYouMean::ClassNameChecker, 1], [Thread::Backtrace, 1], [NameError::message, 1], [NameError, 1], [#<Class:0x00007fbc7e816478>, 1], [Gem::Platform, 1], [IRB::Notifier::CompositeNotifier, 1], [IRB::Notifier::NoMsgNotifier, 1], [Enumerator, 1], [RubyToken::TkSPACE, 1], [FFI::Type::Mapped, 1], [IRB::ReadlineInputMethod, 1], [IRB::WorkSpace, 1], [IRB::Context, 1], [IRB::Irb, 1], [Gem::PathSupport, 1], [Monitor, 1], [IRB::Locale, 1], [DidYouMean::PlainFormatter, 1], [DidYouMean::DeprecatedIgnoredCallers, 1], [IRB::SLex, 1], [RubyLex, 1], [DidYouMean::ClassNameChecker::ClassName, 1], [URI::RFC2396_Parser, 1], [URI::RFC3986_Parser, 1], [Complex, 1], [ThreadGroup, 1], [IOError, 1], [Thread, 1], [RubyVM, 1], [NoMemoryError, 1], [SystemStackError, 1], [Random, 1], [ARGF.class, 1], [Benchmark::IPS::Job::Entry, 1], [Benchmark::IPS::Report, 1], [Benchmark::IPS::Job::StdoutReport, 1], [#<Class:0x00007fbc7e023e50>, 1], [FFI::Pointer, 1], [FFI::FunctionType, 2], [Integer, 2], [IRB::StdioOutputMethod, 2], [Binding, 2], [RubyToken::TkDOT, 2], [RubyToken::TkIDENTIFIER, 2], [FFI::StructLayout, 2], [UnboundMethod, 2], [RubyToken::TkEND, 2], [FFI::DynamicLibrary::Symbol, 2], [FFI::Function, 2], [fatal, 2], [RubyToken::TkNL, 3], [Thread::Mutex, 3], [IRB::Notifier::LeveledNotifier, 3], [IO, 5], [IRB::Inspector, 5], [BigDecimal, 6], [Float, 6], [FFI::StructLayout::Number, 7], [Object, 9], [Range, 17], [FFI::Type::Builtin, 21], [MatchData, 27], [Gem::Specification, 30], [Time, 31], [Module, 71], [IRB::SLex::Node, 78], [Gem::Dependency, 89], [Proc, 91], [Encoding, 101], [Symbol, 127], [Gem::Requirement, 159], [Hash, 188], [Gem::Version, 209], [Gem::StubSpecification, 252], [Gem::StubSpecification::StubLine, 252], [Regexp, 279], [Class, 633], [Array, 1838], [String, 15818]]
```

### Objects by Size

You can break down your objects by size as well, useful for debugging.

```ruby
SPL.objects_by_size do
  ary = []
  35.times do
    ary << (1..99).to_a.sample
  end
end

#=> {:T_OBJECT=>101848, :T_CLASS=>730344, :T_MODULE=>76808, :T_FLOAT=>240, :T_STRING=>882168, :T_REGEXP=>200350, :T_ARRAY=>714384, :T_HASH=>150408, :T_STRUCT=>800, :T_BIGNUM=>80, :T_FILE=>1160, :T_DATA=>1074338, :T_MATCH=>28280, :T_COMPLEX=>40, :T_RATIONAL=>40, :T_SYMBOL=>5080, :T_IMEMO=>325040, :T_ICLASS=>3280, :TOTAL=>4294688}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/schwad_performance_logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SPL project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/schwad_performance_logger/blob/master/CODE_OF_CONDUCT.md).
