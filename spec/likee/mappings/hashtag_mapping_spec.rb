# frozen_string_literal: true

RSpec.describe Likee::HashtagMapping do
  describe '#call' do
    let(:hashtag_data) { load_fixture('single_hashtag_from_get_recommend_hashtag') }
    subject { described_class.new(hashtag_data) }

    it 'parses the hashtag data' do
      hashtag = subject.call

      expect(hashtag.id).to eq('6933972637669342631')
      expect(hashtag.name).to eq('ParaNaPose')
      expect(hashtag.videos_count).to eq(1380)
      expect(hashtag.play_count).to eq(1611960)
    end
  end
end
