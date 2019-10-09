require 'schwad_performance_logger/version'
require 'csv'
require 'logger'
require 'get_process_mem'
require 'benchmark/ips'
require 'objspace'
require 'memory_profiler'
require 'schwad_performance_logger/schwad_performance_logger'

module SchwadPerformanceLogger
  def self.new(opts={})
    if opts.is_a?(Hash)
      PLogger.new(opts)
    else
      puts "I'm sorry, I don't know what you're trying to pass here!\n\n Please refer to the docs or pass an options hash https://github.com/oceanshq/schwad_performance_logger"
    end
  end

  def self.ips
    suppress_output do
      @result = Benchmark.ips do |x|
        x.report("PerformanceLogMethod") do
          yield
        end
      end
    end
    @result
  end

  def self.time
    suppress_output do
      @length_of_time = []
      10.times do
        start_time = Time.now
        yield
        @length_of_time << Time.now - start_time
      end
    end
    puts "Average runtime #{@length_of_time.sum / 10.0} seconds. Max time #{@length_of_time.max}.seconds"
  end

  def self.allocate_count
    # All objects allocated in block
    suppress_output do
      GC.disable
      before = ObjectSpace.count_objects
      yield
      after = ObjectSpace.count_objects
      after.each { |k,v| after[k] = v - before[k] }
      after[:T_HASH] -= 1 # probe effect - we created the before hash.
      after[:FREE] += 1 # same
      GC.enable
      @result = after.reject { |k,v| v == 0 }
    end
    @result
  end

  def self.all_objects
    ObjectSpace.each_object.
      map(&:class).
      each_with_object(Hash.new(0)) { |e, h| h[e] += 1 }.
      sort_by { |k,v| v }
  end

  def self.objects_by_size
    ObjectSpace.count_objects_size
  end

  def self.profile_memory
    suppress_output do
      @report = MemoryProfiler.report do
        yield
      end
    end
    @report.pretty_print
  end

  private

  def self.suppress_output
    original_stderr = $stderr.clone
    original_stdout = $stdout.clone
    $stderr.reopen(File.new('/dev/null', 'w'))
    $stdout.reopen(File.new('/dev/null', 'w'))
    yield
  ensure
    $stdout.reopen(original_stdout)
    $stderr.reopen(original_stderr)
  end
end

SPL = SchwadPerformanceLogger
