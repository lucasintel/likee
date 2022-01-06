# frozen_string_literal: true

RSpec.describe Likee::Api do
  let(:transport) { double(:transport) }

  subject { described_class.new(transport:) }

  describe '#trending_videos' do
    let(:returned_data) { load_fixture('get_square_videos_page1') }

    context 'when called with params' do
      it 'returns trending videos' do
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:post)
          .with(
            endpoint: 'https://api.like-video.com/likee-activity-flow-micro/videoApi/getSquareVideos',
            response_format: :json,
            request_format: :json,
            body: {
              scene: 'WELOG_POPULAR',
              fetchNum: 20,
              startNum: 10,
              lastPostId: '111',
              deviceId: 'did',
              uid: 'uid',
              language: 'ru',
              country: 'RU'
            }
          )
          .and_return(double(:http_response, body: returned_data))

        collection = subject.trending_videos(
          country: 'RU',
          language: 'ru',
          limit: 20,
          start: 10,
          cursor: '111',
          user_id: 'uid',
          device_id: 'did'
        )

        expect(collection[0].id).to eq(Likee::Snowflake.new('7046501523492703838'))
        expect(collection[0].uploaded_at).to eq(Time.parse('2021-12-27 18:44:45 -0300'))
        expect(collection[0].creator_id).to eq('956829278')
        expect(collection[0].creator_username).to eq('aurea777')
        expect(collection[0].creator_nickname).to eq('Áurea')
        expect(collection[0].creator_avatar_url).to eq('https://img.like.video/na_live/3a1/2ywLfj.jpg')
        expect(collection[0].title).to eq('')
        expect(collection[0].description).to eq('#Áurea')
        expect(collection[0].height).to eq(1024)
        expect(collection[0].width).to eq(576)
        expect(collection[0].thumbnail_url).to eq('https://videosnap.like.video/na_live/3a3/0Icw2Z_4.jpg?wmk_sdk=1&type=8')
        expect(collection[0].url).to eq('https://video.like.video/na_live/4aA/0XAxKT_4.mp4?crc=4184195598&type=5')
        expect(collection[0].sound_id).to eq('2751534227492703838')
        expect(collection[0].sound_name).to eq('')
        expect(collection[0].sound_owner_name).to eq('Áurea')
        expect(collection[0].sound_thumbnail).to eq('https://img.like.video/na_live/3a1/2ywLfj.jpg')
        expect(collection[0].likes_count).to eq(1583)
        expect(collection[0].comments_count).to eq(101)
        expect(collection[0].play_count).to eq(58557)
        expect(collection[0].share_count).to eq(723)
        expect(collection[0].hashtags).to eq([Likee::Video::Hashtag.new(id: '6512074516972438446', name: 'Aurea')])
        expect(collection[0].mentions).to eq([])

        expect(collection.count).to eq(28)
      end
    end

    context 'when called without params' do
      it 'uses default params' do
        allow(Likee::Util).to receive(:random_device_id) { 'random_did' }
        allow(Likee::Util).to receive(:random_user_id) { 'random_uid' }
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:post)
          .with(
            endpoint: 'https://api.like-video.com/likee-activity-flow-micro/videoApi/getSquareVideos',
            response_format: :json,
            request_format: :json,
            body: {
              scene: 'WELOG_POPULAR',
              fetchNum: 30,
              startNum: 0,
              lastPostId: 0,
              deviceId: 'random_did',
              uid: 'random_uid',
              language: :en,
              country: :US
            }
          )
          .and_return(double(:http_response, body: returned_data))

        subject.trending_videos
      end
    end

    context 'when called with a custom device_id and user_id from config' do
      subject { described_class.new(transport:, custom_device_id: '111', custom_user_id: '222') }

      it 'uses the custom user and device id' do
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:post)
          .with(
            endpoint: 'https://api.like-video.com/likee-activity-flow-micro/videoApi/getSquareVideos',
            response_format: :json,
            request_format: :json,
            body: {
              scene: 'WELOG_POPULAR',
              fetchNum: 30,
              startNum: 0,
              lastPostId: 0,
              deviceId: '111',
              uid: '222',
              language: :en,
              country: :US
            }
          )
          .and_return(double(:http_response, body: returned_data))

        subject.trending_videos
      end
    end
  end

  describe '#trending_hashtags' do
    let(:returned_data) { load_fixture('get_recommend_hashtag_page1') }

    context 'when called with params' do
      it 'returns trending hashtags' do
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:post)
          .with(
            endpoint: 'https://likee.video/official_website/RecommendApi/getRecommendHashtag',
            response_format: :json,
            request_format: :form_data,
            body: {
              pagesize: 11,
              page: 2,
              language: 'ru',
              country: 'RU'
            }
          )
          .and_return(double(:http_response, body: returned_data))

        collection = subject.trending_hashtags(country: 'RU', language: 'ru', page: 2, per: 11)

        expect(collection[0].id).to eq('6522114720295909590')
        expect(collection[0].name).to eq('PisaMenos')
        expect(collection[0].videos_count).to eq(731)
        expect(collection[0].play_count).to eq(1782553)

        expect(collection.count).to eq(10)
      end
    end

    context 'when called without params' do
      it 'uses default params' do
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:post)
          .with(
            endpoint: 'https://likee.video/official_website/RecommendApi/getRecommendHashtag',
            response_format: :json,
            request_format: :form_data,
            body: {
              pagesize: 100,
              page: 1,
              language: :en,
              country: :US
            }
          )
          .and_return(double(:http_response, body: returned_data))

        subject.trending_hashtags
      end
    end
  end

  describe '#hashtag_videos' do
    let(:returned_data) { load_fixture('get_event_video_page1') }

    context 'when called with params' do
      it 'returns the hashtag videos' do
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:post)
          .with(
            endpoint: 'https://likee.video/official_website/VideoApi/getEventVideo',
            response_format: :json,
            request_format: :form_data,
            body: {
              topicId: 1,
              pageSize: 20,
              page: 2,
              country: 'RU'
            }
          )
          .and_return(double(:http_response, body: returned_data))

        collection = subject.hashtag_videos(
          hashtag_id: 1,
          country: 'RU',
          page: 2,
          per: 20
        )

        expect(collection[0].id).to eq(Likee::Snowflake.new('6931059820922920991'))
        expect(collection[0].uploaded_at).to eq(Time.parse('2021-02-19 16:31:59 -0300'))
        expect(collection[0].creator_id).to eq('1326964767')
        expect(collection[0].creator_username).to eq('sarah.stefano')
        expect(collection[0].creator_nickname).to eq('Sarah Stefano')
        expect(collection[0].creator_avatar_url).to eq('https://img.like.video/na_live/3a1/0mz9bu.jpg')
        expect(collection[0].title).to eq('TREND NOVA')
        expect(collection[0].description).to eq('uma vibe meio WandaVision❤️ || 5 segundos pra comentar um filme com a inicial do seu nome #Popular #PisouMudou ')
        expect(collection[0].height).to eq(1920)
        expect(collection[0].width).to eq(1080)
        expect(collection[0].thumbnail_url).to eq('https://videosnap.like.video/na_live/3a2/1iIf9o_4.jpg?wmk_sdk=1&amp;type=8')
        expect(collection[0].url).to eq('https://video.like.video/na_live/4aq/06Agno_4.mp4?crc=2425041829&type=5')
        expect(collection[0].sound_id).to eq('2636092524922920991')
        expect(collection[0].sound_name).to eq('')
        expect(collection[0].sound_owner_name).to eq('Sarah Stefano')
        expect(collection[0].sound_thumbnail).to eq('https://img.like.video/na_live/3a1/0mz9bu.jpg')
        expect(collection[0].likes_count).to eq(4851)
        expect(collection[0].comments_count).to eq(282)
        expect(collection[0].play_count).to eq(52598)
        expect(collection[0].share_count).to eq(196)
        expect(collection[0].hashtags).to eq(
          [
            Likee::Video::Hashtag.new(id: '6445314485896391170', name: 'Popular'),
            Likee::Video::Hashtag.new(id: '6522114720295909590', name: 'PisaMenos'),
            Likee::Video::Hashtag.new(id: '6931059825217888287', name: 'PisouMudou')
          ]
        )
        expect(collection[0].mentions).to eq([])
        expect(collection[0].country).to eq('BR')

        expect(collection.count).to eq(4)
      end
    end

    context 'when called without params' do
      it 'uses default params' do
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:post)
          .with(
            endpoint: 'https://likee.video/official_website/VideoApi/getEventVideo',
            response_format: :json,
            request_format: :form_data,
            body: {
              topicId: 1,
              pageSize: 50,
              page: 1,
              country: :US
            }
          )
          .and_return(double(:http_response, body: returned_data))

        subject.hashtag_videos(hashtag_id: 1)
      end
    end
  end

  describe '#creator_videos' do
    let(:returned_data) { load_fixture('get_user_video_page1') }

    context 'when called with params' do
      it 'returns the creator videos' do
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:post)
          .with(
            endpoint: 'https://api.like-video.com/likee-activity-flow-micro/videoApi/getUserVideo',
            response_format: :json,
            request_format: :json,
            body: {
              count: 20,
              lastPostId: '111',
              tabType: 0,
              uid: '1'
            }
          )
          .and_return(double(:http_response, body: returned_data))

        collection = subject.creator_videos(user_id: '1', limit: 20, cursor: '111')

        expect(collection[25].id).to eq(Likee::Snowflake.new('6931059820922920991'))
        expect(collection[25].uploaded_at).to eq(Time.parse('2021-02-19 16:31:59 -0300'))
        expect(collection[25].creator_id).to eq('1326964767')
        expect(collection[25].creator_username).to eq('sarah.stefano')
        expect(collection[25].creator_nickname).to eq('Sarah Stefano')
        expect(collection[25].creator_avatar_url).to eq('https://img.like.video/na_live/3a1/0mz9bu.jpg')
        expect(collection[25].title).to eq('TREND NOVA')
        expect(collection[25].description).to eq('uma vibe meio WandaVision❤️ || 5 segundos pra comentar um filme com a inicial do seu nome #Popular #PisouMudou ')
        expect(collection[25].height).to eq(1920)
        expect(collection[25].width).to eq(1080)
        expect(collection[25].thumbnail_url).to eq('https://videosnap.like.video/na_live/3a2/1iIf9o_4.jpg?wmk_sdk=1&type=8')
        expect(collection[25].url).to eq('https://video.like.video/na_live/4aq/06Agno_4.mp4?crc=2425041829&type=5')
        expect(collection[25].sound_id).to eq('2636092524922920991')
        expect(collection[25].sound_name).to eq('')
        expect(collection[25].sound_owner_name).to eq('Sarah Stefano')
        expect(collection[25].sound_thumbnail).to eq('https://img.like.video/na_live/3a1/0mz9bu.jpg')
        expect(collection[25].likes_count).to eq(4851)
        expect(collection[25].comments_count).to eq(282)
        expect(collection[25].play_count).to eq(52599)
        expect(collection[25].share_count).to eq(196)
        expect(collection[25].hashtags).to eq(
          [
            Likee::Video::Hashtag.new(id: '6445314485896391170', name: 'Popular'),
            Likee::Video::Hashtag.new(id: '6522114720295909590', name: 'PisaMenos'),
            Likee::Video::Hashtag.new(id: '6931059825217888287', name: 'PisouMudou')
          ]
        )
        expect(collection[25].mentions).to eq([])
        expect(collection[25].country).to eq('BR')

        expect(collection.count).to eq(30)
      end
    end

    context 'when called without params' do
      it 'uses default params' do
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:post)
          .with(
            endpoint: 'https://api.like-video.com/likee-activity-flow-micro/videoApi/getUserVideo',
            response_format: :json,
            request_format: :json,
            body: {
              count: 100,
              lastPostId: 0,
              tabType: 0,
              uid: '1'
            }
          )
          .and_return(double(:http_response, body: returned_data))

        subject.creator_videos(user_id: '1')
      end
    end
  end

  describe '#video_comments' do
    let(:returned_data) { load_fixture('comments_page1') }

    context 'when called with params' do
      it 'returns the video comments' do
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:get)
          .with(
            endpoint: 'https://likee.video/live/home/comments',
            response_format: :json,
            query_params: {
              post_id: '111',
              lang: 'ru',
              page_size: 10,
              last_comment_id: 5
            }
          )
          .and_return(double(:http_response, body: returned_data))

        collection = subject.video_comments(video_id: '111', language: 'ru', limit: 10, cursor: 5)

        expect(collection[0].id).to eq(Likee::Snowflake.new('6939913204513890335'))
        expect(collection[0].created_at).to eq(Time.parse('2021-03-15 13:07:38 -0300'))
        expect(collection[0].user_id).to eq('1326964767')
        expect(collection[0].user_username).to eq('sarah.stefano')
        expect(collection[0].user_nickname).to eq('Sarah Stefano')
        expect(collection[0].user_avatar_url).to eq('https://img.like.video/na_live/3a1/0mz9bu.jpg')
        expect(collection[0].content).to eq('me sigam nas outras redes sociais! Inst4: @sarah.stefano e app vizinho @hisarahstefano || Quem ja segue comenta &ldquo;❤️&rdquo;')
        expect(collection[0].reply_user_id).to be_nil
        expect(collection[0].reply_user_nickname).to be_nil
        expect(collection[0].reply_content).to be_nil
        expect(collection[0].likes_count).to eq(14)

        expect(collection.count).to eq(19)
      end
    end

    context 'when called without params' do
      it 'uses default params' do
        allow(transport).to receive(:new) { transport }
        expect(transport)
          .to receive(:get)
          .with(
            endpoint: 'https://likee.video/live/home/comments',
            response_format: :json,
            query_params: {
              post_id: '111',
              lang: :en,
              page_size: 49,
              last_comment_id: 0
            }
          )
          .and_return(double(:http_response, body: returned_data))

        subject.video_comments(video_id: '111')
      end
    end
  end

  describe '#find_creator' do
    let(:html_content) do
      <<~HTML
        <script>
          window.data = {\"userinfo\":{\"uid\":\"1326964767\",\"yyuid\":\"sarah.stefano\",\"nick_name\":\"Sarah Stefano\",\"user_name\":\"sarah.stefano\",\"data1\":\"https:\\/\\/img.like.video\\/na_live\\/3a1\\/0mz9bu.jpg\",\"birthday\":\"2002-10-29\",\"exactCountryCode\":\"BR\",\"bigUrl\":\"https:\\/\\/img.like.video\\/na_live\\/3a1\\/0boyQs.jpg\",\"bio\":\"\",\"logo\":[\"https:\\/\\/img.like.video\\/asia_live\\/g1\\/M08\\/2E\\/36\\/Z9PnUFuGmCOEBHgZAAAAAEZUo60327.png?islive=0&id=19\",\"https:\\/\\/img.like.video\\/asia_live\\/4h1\\/M07\\/9A\\/2E\\/yxERAFwcXxSEMPSAAAAAAA2QllM156.png?islive=1&id=98\",\"https:\\/\\/img.like.video\\/asia_live\\/4h6\\/0CFwsE.png?id=169\"],\"gender\":1,\"pendant\":{\"id\":\"\",\"name\":\"\",\"url\":\"\"},\"PGC\":\"{\\\"model\\\":\\\"authentication_title_new_1\\\",\\\"type\\\":\\\"3\\\",\\\"url\\\":\\\"\\\"}\",\"likeeId\":\"sarah.stefano\",\"allLikeCount\":12289869,\"fansCount\":784733,\"followCount\":3582,\"age\":19,\"constellation\":\"Scorpio\"},\"userinfoJson\":\"{\\\"uid\\\":\\\"1326964767\\\",\\\"yyuid\\\":\\\"sarah.stefano\\\",\\\"nick_name\\\":\\\"Sarah Stefano\\\",\\\"user_name\\\":\\\"sarah.stefano\\\",\\\"data1\\\":\\\"https:\\\\\\/\\\\\\/img.like.video\\\\\\/na_live\\\\\\/3a1\\\\\\/0mz9bu.jpg\\\",\\\"birthday\\\":\\\"2002-10-29\\\",\\\"exactCountryCode\\\":\\\"BR\\\",\\\"bigUrl\\\":\\\"https:\\\\\\/\\\\\\/img.like.video\\\\\\/na_live\\\\\\/3a1\\\\\\/0boyQs.jpg\\\",\\\"bio\\\":\\\"\\\",\\\"logo\\\":[\\\"https:\\\\\\/\\\\\\/img.like.video\\\\\\/asia_live\\\\\\/g1\\\\\\/M08\\\\\\/2E\\\\\\/36\\\\\\/Z9PnUFuGmCOEBHgZAAAAAEZUo60327.png?islive=0&id=19\\\",\\\"https:\\\\\\/\\\\\\/img.like.video\\\\\\/asia_live\\\\\\/4h1\\\\\\/M07\\\\\\/9A\\\\\\/2E\\\\\\/yxERAFwcXxSEMPSAAAAAAA2QllM156.png?islive=1&id=98\\\",\\\"https:\\\\\\/\\\\\\/img.like.video\\\\\\/asia_live\\\\\\/4h6\\\\\\/0CFwsE.png?id=169\\\"],\\\"gender\\\":1,\\\"pendant\\\":{\\\"id\\\":\\\"\\\",\\\"name\\\":\\\"\\\",\\\"url\\\":\\\"\\\"},\\\"PGC\\\":\\\"{\\\\\\\"model\\\\\\\":\\\\\\\"authentication_title_new_1\\\\\\\",\\\\\\\"type\\\\\\\":\\\\\\\"3\\\\\\\",\\\\\\\"url\\\\\\\":\\\\\\\"\\\\\\\"}\\\",\\\"likeeId\\\":\\\"sarah.stefano\\\",\\\"allLikeCount\\\":12289869,\\\"fansCount\\\":784733,\\\"followCount\\\":3582,\\\"age\\\":19,\\\"constellation\\\":\\\"Scorpio\\\"}\",\"download\":\"https:\\/\\/like.onelink.me\\/FvnB?pid=Share_profile&c=Share_profile&utm_source=Share_profile\",\"type\":0,\"defaultLogo\":\"https:\\/\\/img.like.video\\/na_live\\/3a1\\/0boyQs.jpg\"};
        window.isEmpty = 0;
        </script>
      HTML
    end

    it 'returns the user profile data' do
      allow(transport).to receive(:new) { transport }
      expect(transport)
        .to receive(:get)
        .with(endpoint: 'https://likee.video/@sarah.stefano')
        .and_return(double(:http_response, body: html_content))

      user = subject.find_creator('sarah.stefano')

      expect(user.id).to eq('1326964767')
      expect(user.username).to eq('sarah.stefano')
      expect(user.nickname).to eq('Sarah Stefano')
      expect(user.avatar_url).to eq('https://img.like.video/na_live/3a1/0boyQs.jpg')
      expect(user.country).to eq('BR')
      expect(user.gender).to eq(:female)
      expect(user.birthday).to eq(Date.parse('2002-10-29'))
      expect(user.star_sign).to eq('Scorpio')
      expect(user.bio).to eq('')
      expect(user.likes_count).to eq(12289869)
      expect(user.fans_count).to eq(784733)
      expect(user.following_count).to eq(3582)
    end
  end
end
