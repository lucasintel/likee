# frozen_string_literal: true

RSpec.describe Likee::CommentMapping do
  describe '#call' do
    context 'comment with quote reply' do
      let(:comment_data) { load_fixture('single_comment_with_reply') }
      subject { described_class.new(comment_data) }

      it 'parses the comment data' do
        comment = subject.call

        expect(comment.id).to eq(Likee::Snowflake.new('7048355918061286644'))
        expect(comment.created_at).to eq(Time.at(1641073245))
        expect(comment.user_id).to eq('445691124')
        expect(comment.user_username).to eq('445691124')
        expect(comment.user_nickname).to eq('ID:885806884')
        expect(comment.content).to eq('hello')
        expect(comment.reply_user_id).to eq('1629264715')
        expect(comment.reply_user_nickname).to eq('Yarine santos ')
        expect(comment.reply_content).to eq('nice good video')
        expect(comment.likes_count).to eq(0)
      end
    end

    context 'single comment' do
      let(:comment_data) { load_fixture('single_comment') }
      subject { described_class.new(comment_data) }

      it 'parses the comment data' do
        comment = subject.call

        expect(comment.id).to eq(Likee::Snowflake.new('7047285198079900385'))
        expect(comment.created_at).to eq(Time.at(1640823948))
        expect(comment.user_id).to eq('2926295777')
        expect(comment.user_username).to eq('robbiecat4stream')
        expect(comment.user_nickname).to eq('robbiecat gg dog')
        expect(comment.content).to eq('early uuu')
        expect(comment.reply_user_id).to be_nil
        expect(comment.reply_user_nickname).to be_nil
        expect(comment.reply_content).to be_nil
        expect(comment.likes_count).to eq(2)
      end
    end
  end
end
