# frozen_string_literal: true

RSpec.describe Likee::VideoMapping do
  describe '#call' do
    context 'POST /likee-activity-flow-micro/videoApi/getUserVideo' do
      context 'when cloudMusic attribute is present' do
        let(:video_data) { load_fixture('single_video_from_get_user_video') }
        subject { described_class.new(video_data) }

        it 'parses the video data' do
          video = subject.call

          expect(video.id).to eq(Likee::Snowflake.new('6928156767853015171'))
          expect(video.uploaded_at).to eq(Time.at(1613087199))
          expect(video.creator_username).to eq('TioDjShow')
          expect(video.creator_id).to eq('2551771267')
          expect(video.creator_nickname).to eq('Dj Boquinhashow')
          expect(video.creator_avatar_url).to eq('https://img.like.video/na_live/3a1/0dSqPh.jpg')
          expect(video.title).to eq('🎉Carnaval Virtual🎊')
          expect(video.description).to eq(' esse ano vai ser assim #CarnavalVirtual #Trendings #Virals #DestaquesDaSemana @Sophiashow💕シ  ')
          expect(video.height).to eq(960)
          expect(video.width).to eq(528)
          expect(video.thumbnail_url).to eq('https://videosnap.like.video/na_live/3a2/1bwgRm_4.jpg?wmk_sdk=1&type=8')
          expect(video.url).to eq('https://video.like.video/na_live/4aB/061bfQ_4.mp4?crc=334407246&type=5')
          expect(video.sound_id).to eq('46997')
          expect(video.sound_name).to eq('Só Depois Do Carnaval')
          expect(video.sound_owner_name).to be_nil
          expect(video.sound_thumbnail).to eq('https://img.like.video/asia_live/4h2/0uexVg.jpg')
          expect(video.likes_count).to eq(602)
          expect(video.comments_count).to eq(27)
          expect(video.play_count).to eq(8257)
          expect(video.share_count).to eq(13)
          expect(video.hashtags).to match_array(
            [
              Likee::Video::Hashtag.new(id: '6461986135898597418', name: 'Virals'),
              Likee::Video::Hashtag.new(id: '6521971805228232672', name: 'Trendings'),
              Likee::Video::Hashtag.new(id: '6677488115831016377', name: 'DestaquesDaSemana'),
              Likee::Video::Hashtag.new(id: '6926415516839971769', name: 'CarnavalVirtual')
            ]
          )
          expect(video.mentions).to eq(
            [
              Likee::Video::Mention.new(id: '1330860176', name: 'Sophiashow💕シ')
            ]
          )
          expect(video.country).to eq('BR')
        end
      end

      context 'when cloudMusic attribute is not present' do
        let(:video_data) { load_fixture('single_video_from_get_user_video_wo_cloud_music') }
        subject { described_class.new(video_data) }

        it 'parses the video data' do
          video = subject.call

          expect(video.sound_id).to eq('2628314853825440072')
          expect(video.sound_name).to eq('XXX')
          expect(video.sound_owner_name).to eq('Willy Wonka')
          expect(video.sound_thumbnail).to eq('https://img.like.video/na_live/3a2/2hDoRr.jpg')
        end
      end

      context 'when both hashtags and mentions are blank' do
        let(:video_data) { load_fixture('single_video_from_get_user_video') }
        subject { described_class.new(video_data) }

        it 'parses the video data' do
          video_data['hashtagInfos'] = '[]'
          video_data['atUserInfos'] = '[]'

          video = subject.call

          expect(video.hashtags).to eq([])
          expect(video.mentions).to eq([])
        end
      end
    end

    context 'POST /official_website/VideoApi/getEventVideo' do
      let(:video_data) { load_fixture('single_video_from_get_event_video') }
      subject { described_class.new(video_data) }

      it 'parses the video data' do
        video = subject.call

        expect(video.id).to eq(Likee::Snowflake.new('6928156767853015171'))
        expect(video.uploaded_at).to eq(Time.at(1613087199))
        expect(video.creator_username).to eq('TioDjShow')
        expect(video.creator_id).to eq('2551771267')
        expect(video.creator_nickname).to eq('Dj Boquinhashow')
        expect(video.creator_avatar_url).to eq('https://img.like.video/na_live/3a1/0dSqPh.jpg')
        expect(video.title).to eq('🎉Carnaval Virtual🎊')
        expect(video.description).to eq(' esse ano vai ser assim #CarnavalVirtual #Trendings #Virals #DestaquesDaSemana @Sophiashow💕シ  ')
        expect(video.height).to eq(960)
        expect(video.width).to eq(528)
        expect(video.thumbnail_url).to eq('https://videosnap.like.video/na_live/3a2/1bwgRm_4.jpg?wmk_sdk=1&type=8')
        expect(video.url).to eq('https://video.like.video/na_live/4aB/061bfQ_4.mp4?crc=334407246&type=5')
        expect(video.sound_id).to eq('46997')
        expect(video.sound_name).to eq('Só Depois Do Carnaval')
        expect(video.sound_owner_name).to be_nil
        expect(video.sound_thumbnail).to eq('https://img.like.video/asia_live/4h2/0uexVg.jpg')
        expect(video.likes_count).to eq(602)
        expect(video.comments_count).to eq(27)
        expect(video.play_count).to eq(8257)
        expect(video.share_count).to eq(13)
        expect(video.hashtags).to match_array(
          [
            Likee::Video::Hashtag.new(id: '6461986135898597418', name: 'Virals'),
            Likee::Video::Hashtag.new(id: '6521971805228232672', name: 'Trendings'),
            Likee::Video::Hashtag.new(id: '6677488115831016377', name: 'DestaquesDaSemana'),
            Likee::Video::Hashtag.new(id: '6926415516839971769', name: 'CarnavalVirtual')
          ]
        )
        expect(video.mentions).to eq(
          [
            Likee::Video::Mention.new(id: '1330860176', name: 'Sophiashow💕シ')
          ]
        )
        expect(video.country).to eq('BR')
      end
    end

    context 'POST /official_website/VideoApi/getVideoInfo' do
      let(:video_data) { load_fixture('single_video_from_get_video_info') }
      subject { described_class.new(video_data) }

      it 'parses the video data' do
        video = subject.call

        expect(video.id).to eq(Likee::Snowflake.new('6928156767853015171'))
        expect(video.uploaded_at).to eq(Time.at(1613087199))
        expect(video.creator_username).to eq('TioDjShow')
        expect(video.creator_id).to eq('2551771267')
        expect(video.creator_nickname).to eq('Dj Boquinhashow')
        expect(video.creator_avatar_url).to eq('https://img.like.video/na_live/3a1/0dSqPh.jpg')
        expect(video.title).to eq('🎉Carnaval Virtual🎊')
        expect(video.description).to eq(' esse ano vai ser assim #CarnavalVirtual #Trendings #Virals #DestaquesDaSemana @Sophiashow💕シ  ')
        expect(video.height).to eq(960)
        expect(video.width).to eq(528)
        expect(video.thumbnail_url).to eq('https://videosnap.like.video/na_live/3a2/1bwgRm_4.jpg?wmk_sdk=1&type=8')
        expect(video.url).to eq('https://video.like.video/na_live/4aB/061bfQ_4.mp4?crc=334407246&type=5')
        expect(video.sound_id).to eq('46997')
        expect(video.sound_name).to eq('Só Depois Do Carnaval')
        expect(video.sound_owner_name).to be_nil
        expect(video.sound_thumbnail).to eq('https://img.like.video/asia_live/4h2/0uexVg.jpg')
        expect(video.likes_count).to eq(602)
        expect(video.comments_count).to eq(27)
        expect(video.play_count).to eq(8257)
        expect(video.share_count).to eq(13)
        expect(video.hashtags).to match_array(
          [
            Likee::Video::Hashtag.new(id: '6461986135898597418', name: 'Virals'),
            Likee::Video::Hashtag.new(id: '6521971805228232672', name: 'Trendings'),
            Likee::Video::Hashtag.new(id: '6677488115831016377', name: 'DestaquesDaSemana'),
            Likee::Video::Hashtag.new(id: '6926415516839971769', name: 'CarnavalVirtual')
          ]
        )
        expect(video.mentions).to eq(
          [
            Likee::Video::Mention.new(id: '1330860176', name: 'Sophiashow💕シ')
          ]
        )
        expect(video.country).to eq('BR')
      end
    end
  end
end
