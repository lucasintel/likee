# frozen_string_literal: true

RSpec.describe 'Creator Videos' do
  before do
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  it 'returns creator videos' do
    api = Likee::Api.new
    collection = api.creator_videos(creator_id: '30007')
    expect(collection).to be_any
  end
end
