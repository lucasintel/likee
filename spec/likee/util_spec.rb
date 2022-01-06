# frozen_string_literal: true

RSpec.describe Likee::Util do
  describe '.dump_json' do
    let(:hash) do
      { a: 1 }
    end

    context 'when Oj is defined' do
      it 'dumps using Oj' do
        allow(Object).to receive(:const_defined?).with(:Oj) { false }
        expect(Oj).to_not receive(:dump)
        expect(hash).to receive(:to_json).and_call_original

        expect(described_class.dump_json(hash)).to eq('{"a":1}')
      end
    end

    context 'when Oj is not defined' do
      it 'dumps using stdlib JSON' do
        allow(Object).to receive(:const_defined?).with(:Oj) { true }
        expect(Oj).to receive(:dump).with(hash, any_args).and_call_original
        expect(hash).to_not receive(:to_json)

        expect(described_class.dump_json(hash)).to eq('{"a":1}')
      end
    end
  end

  describe '.load_json' do
    let(:json) { '{"a":1}' }

    context 'when Oj is defined' do
      it 'dumps using Oj' do
        allow(Object).to receive(:const_defined?).with(:Oj) { false }
        expect(Oj).to_not receive(:load)
        expect(JSON).to receive(:parse).with(json).and_call_original

        expect(described_class.load_json(json)).to eq({ 'a' => 1 })
      end
    end

    context 'when Oj is not defined' do
      it 'dumps using stdlib JSON' do
        allow(Object).to receive(:const_defined?).with(:Oj) { true }
        expect(Oj).to receive(:load).with(json, any_args).and_call_original
        expect(JSON).to_not receive(:parse)

        expect(described_class.load_json(json)).to eq({ 'a' => 1 })
      end
    end
  end

  describe '.monotonic_time' do
    it 'returns the monotonic_time' do
      monotonic_time = double(:monotonic_time)
      allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC) { monotonic_time }

      expect(described_class.monotonic_time).to eq(monotonic_time)
    end
  end

  describe '.random_device_id' do
    it 'generates a random device id' do
      allow(SecureRandom).to receive(:uuid) { '29608418-f57d-41fd-9557-d968b9e65c96' }

      expect(described_class.random_device_id).to eq('29608418f57d41fd9557d968b9e65c96')
    end
  end

  describe '.random_user_id' do
    it 'generates a random user id' do
      allow(Random).to receive(:rand).with(1..9) { 1 }

      expect(described_class.random_user_id).to eq(1111111111)
    end
  end

  describe '.object_identity' do
    it 'returns the object identity' do
      expect(described_class.object_identity(String.new)).to include('String(0x')
    end
  end
end
