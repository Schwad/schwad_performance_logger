##
# Logs performance during life of the object. Defaults to a trifecta of `puts`
# output as well as logging to CSV (in the root folder) and
# `log/schwad_performance_logger` for traditional info-level logging. It also gives
# timing and memory usage info. Options include disabling extra logging,
# including a 'sleep' parameter to have the application pause at each output
# (so your puts info is not drowned). This does not impact the time output
#
# It also puts out delta memory and time so you can see 'between-log' spikes.
#
# This is stored in the system as 'second_delta'
#
class PLogger

  attr_accessor :initial_memory, :initial_time, :current_memory, :last_memory, :current_time, :last_time, :delta_memory, :second_delta_memory, :delta_time, :second_delta_time, :sleep_amount, :sleep_adjuster, :logger

  attr_reader :options

  def initialize( options = {} )
    system('mkdir log')
    system('mkdir log/schwad_performance_logger')
    filename = "./log/schwad_performance_logger/performance-#{Time.now.strftime("%e-%m_%l:%M%p")}.log"
    File.write(filename, "")
    another_empty_csv_row
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
    @sleep_adjuster = -@sleep_amount #This is to remove the sleeps for performance checking.
    log_performance('initialization')
  end

  def log_performance(memo=nil)
    update_checks
    puts_performance(memo) unless @options[:puts] == false
    logger_performance(memo) unless @options[:log] == false
    csv_performance(memo) unless @options[:csv] == false
    sleep @sleep_amount
  end

  private

  def puts_performance(memo)
    puts '*' * 300
    puts "Starting #{memo}. Current memory: #{@current_memory}(Mb), difference of #{@delta_memory} (mb) since beginning and difference of #{@second_delta_memory} since last log. time passed: #{@delta_time} seconds, time since last run: #{@second_delta_time}"
    puts '*' * 300
  end

  def logger_performance(memo)
    @logger.log(1, "#{options[:full_memo]}\n----------------------\n\n#{memo}: \n\n Current Memory: #{@current_memory} \n\n Memory Since Start: #{@delta_memory}\n\n Memory Since Last Run: #{@second_delta_memory}\n\n Time Passed: #{@delta_time} \n\n Time Since Last Run: #{@second_delta_time}\n--------------------\n\n ")
  end

  def another_empty_csv_row
    CSV.open("schwad_performance_logger_measurements.csv", "ab") do |csv|
      csv << []
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
end
