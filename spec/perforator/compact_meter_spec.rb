require 'spec_helper'
require 'logger'

RSpec.describe Perforator::CompactMeter do
  let(:name)              { 'my_meter' }
  let(:logger)            { Logger.new('my_logger.log') }
  let(:execution_message) { 'Hello, Perforator!' }

  let(:compact_meter) do
    described_class.new(
      name:   name,
      logger: logger
    )
  end

  describe '.new' do
    it { expect(compact_meter.name).to   eq name }
    it { expect(compact_meter.logger).to eq logger }
  end

  describe '#call' do
    context 'all options' do
      let(:execute_meter) do
        compact_meter.call do |m|
          m.log! 'Custom message'
        end
      end

      it 'logger receives messages' do
        expect(logger).to receive(:info).with(/"#{name} | Start: 2018-06-25 10:55:48 +0300 | Custom message | Finish: 2018-06-25 10:55:48 +0300 | Spent: 4.6e-05"/).once

        execute_meter
      end

      describe 'set timer attributes' do
        before { execute_meter }

        it { expect(compact_meter.start_time).to_not  be_nil }
        it { expect(compact_meter.finish_time).to_not be_nil }
        it { expect(compact_meter.spent_time).to_not  be_nil }
      end
    end
  end
end
