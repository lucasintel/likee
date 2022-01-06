# frozen_string_literal: true

RSpec.describe Likee do
  describe '.build_api' do
    it 'instantiates and return an Likee::Api instance' do
      instance = double(:instance)
      options = {
        proxy: 'proxy.org'
      }
      expect(Likee::Api).to receive(:new).with(**options) { instance }
      api = described_class.build_api(**options)
      expect(api).to eq(instance)
    end
  end

  describe '.build_client' do
    it 'instantiates and return a Likee::Client instance' do
      instance = double(:instance)
      options = {
        proxy: 'proxy.org'
      }
      expect(Likee::Client).to receive(:new).with(**options) { instance }
      client = described_class.build_client(**options)
      expect(client).to eq(instance)
    end
  end
end
