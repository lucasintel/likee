# frozen_string_literal: true

require_relative 'transport'
require_relative 'mappings/comment_collection_mapping'
require_relative 'mappings/creator_mapping'
require_relative 'mappings/hashtag_collection_mapping'
require_relative 'mappings/video_collection_mapping'
require_relative 'configuration'
require_relative 'util'

module Likee
  class Api
    TRENDING_VIDEOS_ENDPOINT   = 'https://api.like-video.com/likee-activity-flow-micro/videoApi/getSquareVideos'
    CREATOR_VIDEOS_ENDPOINT    = 'https://api.like-video.com/likee-activity-flow-micro/videoApi/getUserVideo'
    TRENDING_HASHTAGS_ENDPOINT = 'https://likee.video/official_website/RecommendApi/getRecommendHashtag'
    HASHTAG_VIDEOS_ENDPOINT    = 'https://likee.video/official_website/VideoApi/getEventVideo'
    VIDEO_COMMENTS_ENDPOINT    = 'https://likee.video/live/home/comments'

    INITIAL_STATE_CREATOR_DATA_REGEX = /"userinfo":(?<user_info>{.*}),"/

    def initialize(
      transport: Likee::Transport,
      user_agent: 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
      referer: 'https://likee.video/',
      custom_device_id: nil,
      custom_user_id: nil,
      keep_alive_idle_timeout: 45,
      open_timeout: 5,
      read_timeout: 5,
      write_timeout: 5,
      proxy: nil
    )
      @config = Likee::Configuration.new(
        user_agent:,
        referer:,
        custom_device_id:,
        custom_user_id:,
        open_timeout:,
        read_timeout:,
        write_timeout:,
        keep_alive_idle_timeout:,
        proxy:
      )
      @transport = transport.new(@config)
      freeze
    end

    # Returns the trending videos from a given location.
    #
    # @param country [String] the country two-letter code (alpha-2)
    # @param language [String] the two-letter language code
    # @param limit [Integer] the number of videos to fetch per iteration
    # @param start [Integer]
    # @param cursor [String] the last video id from the previous iteration
    # @param user_id [String] the user id
    # @param device_id [String] the device id
    #
    # @return [Array<Likee::Video>]
    def trending_videos(country: :US, language: :en, start: 0, cursor: 0, limit: 30, user_id: nil, device_id: nil)
      http_response = transport.post(
        endpoint: TRENDING_VIDEOS_ENDPOINT,
        request_format: :json,
        body: {
          scene: 'WELOG_POPULAR',
          fetchNum: limit,
          startNum: start,
          lastPostId: cursor,
          deviceId: device_id || config.custom_device_id || Util.random_device_id,
          uid: user_id || config.custom_user_id || Util.random_user_id,
          language:,
          country:
        }
      )

      VideoCollectionMapping.(http_response.body)
    end

    # Returns the trending hashtags from a given location.
    #
    # @param country [String] the country two-letter code (alpha-2)
    # @param language [String] the two-letter language code
    # @param page [Integer]
    # @param per [Integer]
    #
    # @return [Array<Likee::Hashtag>]
    def trending_hashtags(country: :US, language: :en, page: 1, per: 100)
      http_response = transport.post(
        endpoint: TRENDING_HASHTAGS_ENDPOINT,
        request_format: :form_url_encoded,
        body: {
          pagesize: per,
          page:,
          language:,
          country:
        }
      )

      HashtagCollectionMapping.(http_response.body)
    end

    # Returns the videos of the given hashtag.
    #
    # @param hashtag_id [String] the hashtag id
    # @param country [String] the country two-letter code (alpha-2)
    # @param page [Integer]
    # @param per [Integer]
    #
    # @return [Array<Likee:Video>]
    def hashtag_videos(hashtag_id:, country: :US, page: 1, per: 50)
      http_response = transport.post(
        endpoint: HASHTAG_VIDEOS_ENDPOINT,
        request_format: :form_url_encoded,
        body: {
          topicId: hashtag_id,
          pageSize: per,
          page:,
          country:
        }
      )

      VideoCollectionMapping.(http_response.body)
    end

    # Finds creator by username.
    #
    # @param username [String] the creator username
    #
    # @return [Array<Likee:Video>]
    def find_creator(username)
      http_response = transport.get(endpoint: "https://likee.video/@#{username}")
      can_extract_data =
        http_response.body =~ INITIAL_STATE_CREATOR_DATA_REGEX
      return unless can_extract_data

      profile_data = Regexp.last_match(1)
      parsed_profile_data = Util.load_json(profile_data)

      Likee::CreatorMapping.(parsed_profile_data)
    end

    # Returns the videos of the given creator.
    #
    # @param user_id [String] the hashtag id
    # @param cursor [String] the last video id from the previous iteration
    # @param limit [Integer] the number of entries to fetch per iteration
    #
    # @return [Array<Likee:Video>]
    def creator_videos(creator_id:, cursor: 0, limit: 100)
      http_response = transport.post(
        endpoint: CREATOR_VIDEOS_ENDPOINT,
        request_format: :json,
        body: {
          count: limit,
          lastPostId: cursor,
          tabType: 0,
          uid: creator_id
        }
      )

      VideoCollectionMapping.(http_response.body)
    end

    # Returns the comments of the given video.
    #
    # @param video_id [String] the video id
    # @param language [String] a two-letter language code
    # @param cursor [Integer] the last comment id from the previous iteration
    # @param limit [Integer] the number of entries to fetch per iteration
    #
    # @return [Array<Likee:Video>]
    def video_comments(video_id:, language: :en, cursor: 0, limit: 49)
      http_response = transport.get(
        endpoint: VIDEO_COMMENTS_ENDPOINT,
        query_params: {
          post_id: video_id,
          lang: language,
          page_size: limit,
          last_comment_id: cursor
        }
      )

      CommentCollectionMapping.(http_response.body)
    end

    private

    attr_reader :transport, :config
  end
end
