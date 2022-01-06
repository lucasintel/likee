# frozen_string_literal: true

RSpec.describe 'Hashtag Videos' do
  before do
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  it 'returns hashtag videos' do
    api = Likee::Api.new
    collection = api.hashtag_videos(hashtag_id: '7034231050079308729')
    expect(collection).to be_any
  end
end
