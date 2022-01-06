# frozen_string_literal: true

RSpec.describe Likee::CreatorMapping do
  describe '#call' do
    let(:creator_data) { load_fixture('creator_profile_data') }
    subject { described_class.new(creator_data) }

    it 'parses the creator data' do
      creator = subject.call

      expect(creator.id).to eq('30007')
      expect(creator.username).to eq('Likee_USA')
      expect(creator.nickname).to eq('Likee US')
      expect(creator.avatar_url).to eq('https://img.like.video/asia_live/3s2/0dwqyT.jpg')
      expect(creator.country).to eq('US')
      expect(creator.gender).to eq(:male)
      expect(creator.birthday).to eq(Date.new(2014, 2, 3))
      expect(creator.star_sign).to eq('Aquarius')
      expect(creator.bio).to eq('bio content')
      expect(creator.likes_count).to eq(14891646)
      expect(creator.fans_count).to eq(33493455)
      expect(creator.following_count).to eq(1071)
    end
  end
end
