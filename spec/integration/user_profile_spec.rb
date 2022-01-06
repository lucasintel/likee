# frozen_string_literal: true

RSpec.describe 'Creator Profile' do
  before do
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  it 'finds a creator by username' do
    api = Likee::Api.new
    creator = api.find_creator('Likee_USA')
    expect(creator.id).to eq('30007')
  end
end
