module Perforator
  class CompactMeter
    DELIMETER = ' | '.freeze

    attr_reader :name, :logger, :expected_time,:positive_callback,
      :negative_callback, :start_time, :finish_time, :spent_time

    def initialize(options = {})
      @name   = options.fetch(:name,   nil)
      @logger = options.fetch(:logger, nil)
    end

    def call(&block)
      start

      yield(self)

      finish
    end

    def log!(content)
      log_items << content
    end

    private

    alias_method :process_logger?, :logger

    def log_items
      @log_items ||= []
    end

    def start
      log! name

      @start_time = Time.now

      log! "Start: #{start_time}"
    end

    def finish
      @finish_time = Time.now
      @spent_time = finish_time - start_time

      log! "Finish: #{finish_time}"
      log! "Spent: #{spent_time}"

      release_logs!
    end

    def release_logs!
      logger.info(log_items.join(DELIMETER)) if process_logger?
    end
  end
end
