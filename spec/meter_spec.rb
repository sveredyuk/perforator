require 'spec_helper'
require 'logger'

RSpec.describe Perforator::Meter do
  let(:name)              { 'my_meter' }
  let(:logger)            { Logger.new('my_logger.log') }
  let(:expected_time)     { 20 }
  let(:positive_callback) { -> { ':)' } }
  let(:negative_callback) { -> { ':(' } }
  let(:execution_message) { 'Hello, Perforator!' }

  let(:meter) do
    described_class.new(
      name:              name,
      logger:            logger,
      puts:              true,
      expected_time:     expected_time,
      positive_callback: positive_callback,
      negative_callback: negative_callback
    )
  end

  describe '.initialize' do
    it { expect(meter.name).to              eq name }
    it { expect(meter.logger).to            eq logger }
    it { expect(meter.expected_time).to     eq expected_time }
    it { expect(meter.positive_callback).to eq positive_callback }
    it { expect(meter.negative_callback).to eq negative_callback }
    it { expect(meter.start_time).to        eq nil }
    it { expect(meter.finish_time).to       eq nil }
    it { expect(meter.spent_time).to        eq nil }

    context 'with not integer expected_time' do
      let(:bad_expected_time_meter) { described_class.new(expected_time: '10') }

      it { expect{bad_expected_time_meter}.to raise_exception(Perforator::Meter::NotFixnumExpectedTimeError) }
    end

    context 'with callbacks but without expected_time' do
      let(:bad_positive_meter) { described_class.new(expected_time: 10, positive_callback: Hash.new) }
      let(:bad_negative_meter) { described_class.new(expected_time: 10, negative_callback: Hash.new) }

      it { expect{bad_positive_meter}.to raise_exception(Perforator::Meter::NotCallableCallbackError) }
      it { expect{bad_negative_meter}.to raise_exception(Perforator::Meter::NotCallableCallbackError) }
    end

    context 'with not callable callbacks' do
      let(:bad_positive_meter) { described_class.new(positive_callback: positive_callback) }
      let(:bad_negative_meter) { described_class.new(negative_callback: negative_callback) }

      it { expect{bad_positive_meter}.to raise_exception(Perforator::Meter::NoExpectedTimeError) }
      it { expect{bad_negative_meter}.to raise_exception(Perforator::Meter::NoExpectedTimeError) }
    end
  end

  describe '.call' do
    context 'all options' do
      def default_loggger_and_puts_messages_receiving
        expect(logger).to receive(:info).with(/Start:/).once
        expect(STDOUT).to receive(:puts).with(/Start:/).once

        expect(logger).to receive(:info).with("=======> #{name}").once
        expect(STDOUT).to receive(:puts).with("=======> #{name}").once

        expect(logger).to receive(:info).with(/Finish:/).once
        expect(STDOUT).to receive(:puts).with(/Finish:/).once

        expect(logger).to receive(:info).with(/Spent:/).once
        expect(STDOUT).to receive(:puts).with(/Spent:/).once

        expect(STDOUT).to receive(:puts).with(execution_message).once
      end

      let(:execute_meter) do
        meter.call do
          puts execution_message
        end
      end

      it 'logger receives messages' do
        default_loggger_and_puts_messages_receiving

        expect(logger).to receive(:info).with(/Spent time less than exepcted. Executing:/).once
        expect(STDOUT).to receive(:puts).with(/Spent time less than exepcted. Executing:/).once

        execute_meter
      end

      it 'execute positive callback' do
        expect(positive_callback).to receive(:call)
        expect(negative_callback).to_not receive(:call)

        execute_meter
      end

      it 'execute negative callback in case of increasing expected time' do
        allow(meter).to receive(:spent_time) { expected_time + 1 }

        expect(negative_callback).to receive(:call)
        expect(positive_callback).to_not receive(:call)

        default_loggger_and_puts_messages_receiving
        expect(logger).to receive(:info).with(/Spent time more than exepcted. Executing:/).once
        expect(STDOUT).to receive(:puts).with(/Spent time more than exepcted. Executing:/).once

        execute_meter
      end

      describe 'set timer attributes' do
        before { execute_meter }

        it { expect(meter.start_time).to_not  be_nil }
        it { expect(meter.finish_time).to_not be_nil }
        it { expect(meter.spent_time).to_not  be_nil }
      end
    end

    context 'no options' do
      let(:execute_simple_meter) do
        described_class.new.call do
          puts execution_message
        end
      end

      it 'not touch anything' do
        expect(logger).to_not receive(:info).with(execution_message)
        expect(STDOUT).to receive(:puts).with(execution_message).once
        expect(negative_callback).to_not receive(:call)
        expect(positive_callback).to_not receive(:call)

        execute_simple_meter
      end
    end
  end
end
