require 'logger'
require 'csv'
require 'get_process_mem'

class PLogger
  attr_accessor :initial_memory, :initial_time, :current_memory, :last_memory, :current_time, :last_time, :delta_memory, :second_delta_memory, :delta_time, :second_delta_time, :sleep_amount, :sleep_adjuster, :logger
  attr_reader :options

  def initialize(options = {})
    system('mkdir -p log/schwad_performance_logger')
    filename = "./log/schwad_performance_logger/performance-#{Time.now.strftime("%e-%m_%l:%M%p")}.log"
    File.write(filename, "")
    initialize_csv
    @logger = Logger.new(filename)
    @options = options
    @sleep_amount = options[:pause].to_i
    @initial_memory = GetProcessMem.new.mb.round
    @current_memory = @initial_memory
    @delta_memory = 0
    @delta_time = 0
    @initial_time = Time.now
    @current_time = @initial_time
    @last_time = @initial_time
    @last_memory = @initial_memory
    @sleep_adjuster = -@sleep_amount # This is to remove the sleeps for performance checking.
    log_performance('initialization')
  end

  def log_performance(memo = nil, minimal: false)
    if block_given?
      update_checks
      yield
      update_checks
      puts_performance("After: #{memo}", gblock: true, minimal: minimal) unless @options[:puts] == false
      logger_performance("After: #{memo}") unless @options[:log] == false
      csv_performance("After: #{memo}") unless @options[:csv] == false
    else
      update_checks
      puts_performance(memo, minimal: minimal) unless @options[:puts] == false
      logger_performance(memo) unless @options[:log] == false
      csv_performance(memo) unless @options[:csv] == false
    end
    sleep @sleep_amount
  end
  alias :log :log_performance
  alias :lp :log_performance

  private

  def puts_performance(memo, gblock: false, minimal: false)
    separator = '*' * 80
    puts "\e[34m#{separator}\e[0m"
    puts "\e[32m#{memo}\e[0m"
    if minimal
      puts format_output_minimal
    elsif gblock
      puts format_output_block
    else
      puts format_output
    end
    puts "\e[34m#{separator}\e[0m"
  end

  def logger_performance(memo)
    @logger.info("#{options[:full_memo]}\n----------------------\n\n#{memo}:\n\n#{format_output}\n--------------------\n\n")
  end

  def initialize_csv
    CSV.open("schwad_performance_logger_measurements.csv", "wb") do |csv|
      csv << ["Full Memo", "Memo", "Current Memory (Mb)", "Memory Since Start (Mb)", "Memory Since Last Log (Mb)", "Time Passed (s)", "Time Since Last Run (s)"]
    end
  end

  def csv_performance(memo)
    CSV.open("schwad_performance_logger_measurements.csv", "ab") do |csv|
      csv << [@options[:full_memo], memo, @current_memory, @delta_memory, @second_delta_memory, @delta_time, @second_delta_time]
    end
  end

  def update_checks
    @sleep_adjuster += @sleep_amount
    @last_memory = @current_memory
    @current_memory = GetProcessMem.new.mb.round
    @second_delta_memory = @current_memory - @last_memory
    @delta_memory = @current_memory - @initial_memory
    @last_time = @current_time
    @current_time = Time.now
    @second_delta_time = @current_time - @last_time
    @delta_time = (@current_time - @initial_time) - @sleep_adjuster
  end

  def format_output_block
    <<~OUTPUT
      \e[33mCurrent memory:\e[0m          #{@current_memory} Mb
      \e[33mDifference since start:\e[0m  #{@delta_memory} Mb
      \e[33mMemory used within block:\e[0m #{@second_delta_memory} Mb
      \e[33mTime passed:\e[0m             #{@delta_time * 1000} milliseconds
      \e[33mTime executing block:\e[0m     #{@second_delta_time * 1000} milliseconds
    OUTPUT
  end

  def format_output
    <<~OUTPUT
      \e[33mCurrent memory:\e[0m          #{@current_memory} Mb
      \e[33mDifference since start:\e[0m  #{@delta_memory} Mb
      \e[33mDifference since last log:\e[0m #{@second_delta_memory} Mb
      \e[33mTime passed:\e[0m             #{@delta_time * 1000} milliseconds
      \e[33mTime since last run:\e[0m     #{@second_delta_time * 1000} milliseconds
    OUTPUT
  end

  def format_output_minimal
    <<~OUTPUT
      #{@second_delta_time * 1000}ms
    OUTPUT
  end
end
