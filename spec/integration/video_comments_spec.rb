# frozen_string_literal: true

RSpec.describe 'Video Comments' do
  before do
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  it 'returns video comments' do
    api = Likee::Api.new
    collection = api.video_comments(video_id: '7025013457556632887')
    expect(collection).to be_any
  end
end
