# frozen_string_literal: true

RSpec.describe Likee::Instrumentation do
  before do
    described_class.clear
  end

  after do
    described_class.clear
  end

  describe '#subscribe' do
    it 'subscribes with block' do
      callable = -> {}
      described_class.subscribe('spec', &callable)
      expect(described_class.subscribers).to include('spec' => callable)
    end

    it 'raises error when block is not given' do
      expect { described_class.subscribe }.to raise_exception(ArgumentError, '#subscribe expects a block')
    end
  end

  describe '#unsubscribe' do
    it 'unsubscribes the given subscriber' do
      described_class.subscribe('spec') { nil }
      expect(described_class.subscribers.keys).to include('spec')

      described_class.unsubscribe('spec')
      expect(described_class.subscribers.keys).to_not include('spec')
    end
  end

  describe '#notify' do
    let(:metrics_collector) { double(:metrics_collector) }
    let(:config) { double(:config) }
    let(:exception) { double(:exception) }

    it 'notifies subscribers' do
      expect(metrics_collector).to receive(:incr).twice

      described_class.subscribe do |event|
        expect(event.duration).to eq(10)
        expect(event.http_status).to eq(200)
        expect(event.method).to eq(:get)
        expect(event.url).to eq('https://test.host/endpoint')
        expect(event.config).to eq(config)
        expect(event.exception).to eq(exception)

        metrics_collector.incr
      end

      described_class.subscribe do |_event|
        metrics_collector.incr
      end

      described_class.notify(
        duration: 10,
        http_status: 200,
        method: :get,
        url: 'https://test.host/endpoint',
        config:,
        exception:
      )
    end
  end

  describe '#clear' do
    it 'clears the subscriber list' do
      described_class.subscribe { nil }
      described_class.subscribe { nil }

      expect(described_class.subscribers.count).to eq(2)

      described_class.clear

      expect(described_class.subscribers.count).to eq(0)
    end
  end

  describe '#subscribers' do
    it 'returns the subscriber list' do
      block1 = -> {}
      block2 = -> {}

      described_class.subscribe('spec1', &block1)
      described_class.subscribe('spec2', &block2)

      expect(described_class.subscribers).to include(
        'spec1' => block1,
        'spec2' => block2
      )
    end
  end
end
