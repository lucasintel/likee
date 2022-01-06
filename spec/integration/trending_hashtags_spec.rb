# frozen_string_literal: true

RSpec.describe 'Trending Hashtags' do
  before do
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  it 'returns trending hashtags' do
    api = Likee::Api.new
    collection = api.trending_hashtags
    expect(collection).to be_any
  end
end
