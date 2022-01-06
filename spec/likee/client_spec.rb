# frozen_string_literal: true

RSpec.describe Likee::Client do
  let(:api) { double(:api) }

  subject { described_class.new(api_class: api) }

  describe '#find_creator' do
    let(:creator) { build(:creator) }
    let(:creator_videos_page1) { build_list(:video, 5) }
    let(:creator_videos_page2) { build_list(:video, 5) }
    let(:creator_videos_page3) { [] }
    let(:comments_page1) { build_list(:comment, 5) }
    let(:comments_page2) { build_list(:comment, 5) }
    let(:comments_page3) { [] }

    it 'paginates through the creator profile' do
      expect(api).to receive(:new) { api }
      expect(api).to receive(:find_creator).with('username') { creator }
      expect(api)
        .to receive(:creator_videos)
        .with(creator_id: creator.id, cursor: 0)
        .and_return(creator_videos_page1)
      expect(api)
        .to receive(:creator_videos)
        .with(creator_id: creator.id, cursor: creator_videos_page1.last.id)
        .and_return(creator_videos_page2)
      expect(api)
        .to receive(:creator_videos)
        .with(creator_id: creator.id, cursor: creator_videos_page2.last.id)
        .and_return(creator_videos_page3)

      creator = subject.find_creator('username')

      expect(creator.id).to eq(creator.id)
      expect(creator.username).to eq(creator.username)
      expect(creator.avatar_url).to eq(creator.avatar_url)
      expect(creator.country).to eq(creator.country)
      expect(creator.gender).to eq(creator.gender)
      expect(creator.birthday).to eq(creator.birthday)
      expect(creator.star_sign).to eq(creator.star_sign)
      expect(creator.bio).to eq(creator.bio)
      expect(creator.likes_count).to eq(creator.likes_count)
      expect(creator.fans_count).to eq(creator.fans_count)
      expect(creator.following_count).to eq(creator.following_count)

      returned_video_ids = creator.videos.map { |video| video.id.to_s }
      expected_video_ids = (creator_videos_page1 + creator_videos_page2 + creator_videos_page3).map { |video| video.id.to_s }

      expect(returned_video_ids).to match_array(expected_video_ids)
    end

    it 'paginates through video comments' do
      expect(api).to receive(:new) { api }
      expect(api).to receive(:find_creator).with('username') { creator }
      expect(api)
        .to receive(:creator_videos)
        .with(creator_id: creator.id, cursor: 0)
        .and_return(creator_videos_page1)

      creator = subject.find_creator('username')
      video = creator.videos.first

      expect(api)
        .to receive(:video_comments)
        .with(video_id: video.id, cursor: 0)
        .and_return(comments_page1)

      expect(api)
        .to receive(:video_comments)
        .with(video_id: video.id, cursor: comments_page1.last.id)
        .and_return(comments_page2)

      expect(api)
        .to receive(:video_comments)
        .with(video_id: video.id, cursor: comments_page2.last.id)
        .and_return(comments_page3)

      returned_comment_ids = video.comments.map { |comment| comment.id.to_s }
      expected_comment_ids = (comments_page1 + comments_page2 + comments_page3).map { |comment| comment.id.to_s }

      expect(returned_comment_ids).to match_array(expected_comment_ids)
    end

    it 'associates creator and its videos' do
      expect(api).to receive(:new) { api }
      expect(api).to receive(:find_creator).with('username') { creator }
      expect(api)
        .to receive(:creator_videos)
        .with(creator_id: creator.id, cursor: 0)
        .and_return(creator_videos_page1)

      creator = subject.find_creator('username')
      video = creator.videos.first

      expect(video.creator).to eq(creator)
    end

    it 'associates videos and its comments' do
      expect(api).to receive(:new) { api }
      expect(api).to receive(:find_creator).with('username') { creator }
      expect(api)
        .to receive(:creator_videos)
        .with(creator_id: creator.id, cursor: 0)
        .and_return(creator_videos_page1)

      creator = subject.find_creator('username')
      video = creator.videos.first

      expect(api)
        .to receive(:video_comments)
        .with(video_id: video.id, cursor: 0)
        .and_return(comments_page1)

      comment = video.comments.first

      expect(comment.video).to eq(video)
    end

    it 'reads creator properties' do
      expect(api).to receive(:new) { api }
      expect(api).to receive(:find_creator).with('username') { creator }

      creator = subject.find_creator('username')

      expect(creator.id).to eq(creator.id)
      expect(creator.username).to eq(creator.username)
      expect(creator.avatar_url).to eq(creator.avatar_url)
      expect(creator.country).to eq(creator.country)
      expect(creator.gender).to eq(creator.gender)
      expect(creator.birthday).to eq(creator.birthday)
      expect(creator.star_sign).to eq(creator.star_sign)
      expect(creator.bio).to eq(creator.bio)
      expect(creator.likes_count).to eq(creator.likes_count)
      expect(creator.fans_count).to eq(creator.fans_count)
      expect(creator.following_count).to eq(creator.following_count)
    end

    it 'reads video properties' do
      expect(api).to receive(:new) { api }
      expect(api).to receive(:find_creator).with('username') { creator }
      expect(api)
        .to receive(:creator_videos)
        .with(creator_id: creator.id, cursor: 0)
        .and_return(creator_videos_page1)

      creator = subject.find_creator('username')
      video = creator.videos.first

      expect(video.id).to eq(creator_videos_page1[0].id)
      expect(video.uploaded_at).to eq(creator_videos_page1[0].uploaded_at)
      expect(video.creator_id).to eq(creator_videos_page1[0].creator_id)
      expect(video.creator_username).to eq(creator_videos_page1[0].creator_username)
      expect(video.creator_nickname).to eq(creator_videos_page1[0].creator_nickname)
      expect(video.creator_avatar_url).to eq(creator_videos_page1[0].creator_avatar_url)
      expect(video.title).to eq(creator_videos_page1[0].title)
      expect(video.description).to eq(creator_videos_page1[0].description)
      expect(video.height).to eq(creator_videos_page1[0].height)
      expect(video.width).to eq(creator_videos_page1[0].width)
      expect(video.thumbnail_url).to eq(creator_videos_page1[0].thumbnail_url)
      expect(video.url).to eq(creator_videos_page1[0].url)
      expect(video.sound_id).to eq(creator_videos_page1[0].sound_id)
      expect(video.sound_name).to eq(creator_videos_page1[0].sound_name)
      expect(video.sound_owner_name).to eq(creator_videos_page1[0].sound_owner_name)
      expect(video.sound_thumbnail).to eq(creator_videos_page1[0].sound_thumbnail)
      expect(video.likes_count).to eq(creator_videos_page1[0].likes_count)
      expect(video.comments_count).to eq(creator_videos_page1[0].comments_count)
      expect(video.play_count).to eq(creator_videos_page1[0].play_count)
      expect(video.share_count).to eq(creator_videos_page1[0].share_count)
      expect(video.hashtags).to eq(creator_videos_page1[0].hashtags)
      expect(video.mentions).to eq(creator_videos_page1[0].mentions)
      expect(video.country).to eq(creator_videos_page1[0].country)
    end

    it 'reads comment properties' do
      expect(api).to receive(:new) { api }
      expect(api).to receive(:find_creator).with('username') { creator }
      expect(api)
        .to receive(:creator_videos)
        .with(creator_id: creator.id, cursor: 0)
        .and_return(creator_videos_page1)

      creator = subject.find_creator('username')
      video = creator.videos.first

      expect(api)
        .to receive(:video_comments)
        .with(video_id: video.id, cursor: 0)
        .and_return(comments_page1)

      comment = video.comments.first

      expect(comment.id).to eq(comments_page1[0].id)
      expect(comment.created_at).to eq(comments_page1[0].created_at)
      expect(comment.user_id).to eq(comments_page1[0].user_id)
      expect(comment.user_username).to eq(comments_page1[0].user_username)
      expect(comment.user_nickname).to eq(comments_page1[0].user_nickname)
      expect(comment.user_avatar_url).to eq(comments_page1[0].user_avatar_url)
      expect(comment.content).to eq(comments_page1[0].content)
      expect(comment.likes_count).to eq(comments_page1[0].likes_count)
      expect(comment.reply_user_id).to eq(comments_page1[0].reply_user_id)
      expect(comment.reply_user_nickname).to eq(comments_page1[0].reply_user_nickname)
      expect(comment.reply_content).to eq(comments_page1[0].reply_content)
    end
  end

  describe '#trending_videos' do
    let(:creator) { build(:creator) }
    let(:trending_videos_page1) { build_list(:video, 5) }
    let(:trending_videos_page2) { build_list(:video, 5) }
    let(:trending_videos_page3) { [] }

    it 'paginates through the trending videos' do
      expect(api).to receive(:new) { api }
      expect(api)
        .to receive(:trending_videos)
        .with(country: 'RU', language: 'ru', start: 0, cursor: 0)
        .and_return(trending_videos_page1)
      expect(api)
        .to receive(:trending_videos)
        .with(country: 'RU', language: 'ru', start: 0, cursor: trending_videos_page1.last.id)
        .and_return(trending_videos_page2)
      expect(api)
        .to receive(:trending_videos)
        .with(country: 'RU', language: 'ru', start: 0, cursor: trending_videos_page2.last.id)
        .and_return(trending_videos_page3)

      videos = subject.trending_videos(country: 'RU', language: 'ru')

      returned_video_ids = videos.map { |video| video.id.to_s }
      expected_video_ids = (trending_videos_page1 + trending_videos_page2 + trending_videos_page3).map { |video| video.id.to_s }

      expect(returned_video_ids).to match_array(expected_video_ids)
    end

    it 'associates users and its creators' do
      expect(api).to receive(:new) { api }
      expect(api)
        .to receive(:trending_videos)
        .with(country: 'RU', language: 'ru', start: 0, cursor: 0)
        .and_return(trending_videos_page1)

      videos = subject.trending_videos(country: 'RU', language: 'ru')
      video = videos.first

      expect(api).to receive(:find_creator).with(video.creator_username) { creator }

      expect(video.creator.id).to eq(creator.id)
    end
  end
end
