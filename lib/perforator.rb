require 'perforator/version'

module Perforator
  class Meter
    NoExpectedTimeError        = Class.new(StandardError)
    NotCallableCallbackError   = Class.new(StandardError)
    NotFixnumExpectedTimeError = Class.new(StandardError)

    attr_reader :name, :logger, :expected_time,:positive_callback,
      :negative_callback, :start_time, :finish_time, :spent_time

    def initialize(options = {})
      @name              = options.fetch(:name,              nil)
      @logger            = options.fetch(:logger,            nil)
      @process_puts      = options.fetch(:puts,            false)
      @expected_time     = options.fetch(:expected_time,     nil)
      @positive_callback = options.fetch(:positive_callback, nil)
      @negative_callback = options.fetch(:negative_callback, nil)

      raise NoExpectedTimeError if callbacks_without_expected_time?
      raise NotFixnumExpectedTimeError unless expected_time_valid?
      raise NotCallableCallbackError unless callable_callbacks?
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

    attr_reader :process_puts

    alias_method :process_puts?, :process_puts
    alias_method :process_logger?, :logger

    def log_items
      @log_items ||= []
    end

    def start
      log! "=======> #{name}"

      @start_time = Time.now

      log! "Start: #{start_time}"
    end

    def finish
      @finish_time = Time.now
      @spent_time = finish_time - start_time

      log! "Finish: #{finish_time}"
      log! "Spent: #{spent_time}"

      execute_callbacks!
      release_logs!
    end

    def execute_callbacks!
      return unless expected_time

      if spent_time < expected_time && positive_callback
        log! "Spent time less than exepcted. Executing: #{positive_callback.inspect}"
        positive_callback.call
      elsif spent_time > expected_time && negative_callback
        log! "Spent time more than exepcted. Executing: #{negative_callback.inspect}"
        negative_callback.call
      end
    end

    def release_logs!
      log_items.each do |log_item|
        puts(log_item)        if process_puts?
        logger.info(log_item) if process_logger?
      end
    end

    def callbacks_without_expected_time?
      (positive_callback || negative_callback) && !expected_time
    end

    def callable_callbacks?
      callbacks = [positive_callback, negative_callback].compact

      return true if callbacks.empty?

      callbacks.map { |c| c.respond_to?(:call) }.uniq == [true]
    end

    def expected_time_valid?
      expected_time.nil? || expected_time.is_a?(Fixnum)
    end
  end
end
