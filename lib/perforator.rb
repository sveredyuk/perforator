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
      @puts              = options.fetch(:puts,            false)
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

    def puts?
      @puts
    end

    private

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
    end

    def execute_callbacks!
      return unless expected_time

      if spent_time < expected_time
        log! "Spent time less than exepcted. Executing: #{positive_callback.inspect}"
        positive_callback.call
      else
        log! "Spent time more than exepcted. Executing: #{positive_callback.inspect}"
        negative_callback.call
      end
    end

    def log!(content)
      puts(content)        if puts?
      logger.info(content) if logger
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

    # TODO Add possibility to log method_missing keys
    def method_missing(meth, *args, &blk)
      log!("#{meth}: #{args[0]}")
    end
  end
end
