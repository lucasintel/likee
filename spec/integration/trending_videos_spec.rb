# frozen_string_literal: true

RSpec.describe 'Trending Videos' do
  before do
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  it 'returns trending videos' do
    api = Likee::Api.new
    collection = api.trending_videos
    expect(collection).to be_any
  end
end
