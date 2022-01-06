# frozen_string_literal: true

require_relative 'transport'
require_relative 'mappings/comment_mapping'
require_relative 'mappings/creator_mapping'
require_relative 'mappings/hashtag_mapping'
require_relative 'mappings/video_mapping'
require_relative 'configuration'
require_relative 'util'

module Likee
  class Api
    TRENDING_VIDEOS_ENDPOINT = 'https://api.like-video.com/likee-activity-flow-micro/videoApi/getSquareVideos'
    CREATOR_VIDEOS_ENDPOINT = 'https://api.like-video.com/likee-activity-flow-micro/videoApi/getUserVideo'
    TRENDING_HASHTAGS_ENDPOINT = 'https://likee.video/official_website/RecommendApi/getRecommendHashtag'
    HASHTAG_VIDEOS_ENDPOINT = 'https://likee.video/official_website/VideoApi/getEventVideo'
    VIDEO_COMMENTS_ENDPOINT = 'https://likee.video/live/home/comments'

    INITIAL_STATE_CREATOR_DATA_REGEX = /"userinfo":(?<user_info>{.*}),"/

    private_constant :INITIAL_STATE_CREATOR_DATA_REGEX

    class LikeeResponse
      attr_reader :code, :data

      def initialize(code:, data:)
        @code = code
        @data = data
        freeze
      end

      def success?
        code.zero?
      end

      def error?
        !success?
      end
    end

    # Instantiates a low level API client used to interact with Likee.
    #
    # @param user_agent [String] the User-Agent header used by the library
    # @param referer [String] the Referer header used by the library
    # @param custom_device_id [String] optional, the library generates a random
    #   device ID for each request, however you might want to set a consistent
    #   one to improve recommendations
    # @param custom_user_id [String] optional, the library generates a random
    #   user ID for each request, however you might want to set a consistent one
    #   to improve recommendations
    # @param keep_alive_timeout [Integer] the Keep-Alive timeout
    # @param open_timeout [Integer]
    # @param read_timeout [Integer]
    # @param write_timeout [Integer]
    # @param proxy [String] optional, a string containing your proxy address
    #
    # @return [Likee::Api]
    def initialize(
      transport: Likee::Transport,
      user_agent: 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
      referer: 'https://likee.video/',
      custom_device_id: nil,
      custom_user_id: nil,
      keep_alive_timeout: 30,
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
        keep_alive_timeout:,
        proxy:
      )
      @transport = transport.new(@config)
      freeze
    end

    # Explore trending videos from a given location.
    #
    # @param country [String] the target country code
    # @param language [String] the target language
    # @param limit [Integer] the number of posts per iteration
    # @param start [Integer] the recommendation offset
    # @param cursor [String] the last video ID from the previous iteration
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

      response = build_response(http_response)
      return [] if response.error?

      collection = response.data['videoList']
      return [] if collection.nil? || !collection.is_a?(Array)

      Likee::VideoMapping.map_collection(collection)
    end

    # Explore trending hashtags from a given location.
    #
    # @param country [String] the target country code
    # @param language [String] the target language
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

      response = build_response(http_response)
      return [] if response.error?

      collection = response.data['eventList']
      return [] if collection.nil? || !collection.is_a?(Array)

      Likee::HashtagMapping.map_collection(collection)
    end

    # Explore videos from a given hashtag.
    #
    # @param hashtag_id [String] the hashtag ID
    # @param country [String] the target country code
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

      response = build_response(http_response)
      return [] if response.error?

      collection = response.data['videoList']
      return [] if collection.nil? || !collection.is_a?(Array)

      Likee::VideoMapping.map_collection(collection)
    end

    # Find creators by username.
    #
    # @param username [String] the creator username
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

    # Explore videos from a given creator.
    #
    # @param user_id [String] the hashtag ID
    # @param cursor [String] the last video ID from the previous iteration
    # @param limit [Integer] the number of entries per iteration
    #
    # @return [Array<Likee:Video>]
    def creator_videos(user_id:, cursor: 0, limit: 100)
      http_response = transport.post(
        endpoint: CREATOR_VIDEOS_ENDPOINT,
        request_format: :json,
        body: {
          count: limit,
          lastPostId: cursor,
          tabType: 0,
          uid: user_id
        }
      )

      response = build_response(http_response)
      return [] if response.error?

      collection = response.data['videoList']
      return [] if collection.nil? || !collection.is_a?(Array)

      Likee::VideoMapping.map_collection(collection)
    end

    # View comments from a given video.
    #
    # @param video_id [String] the hashtag ID
    # @param language [String] the desired language
    # @param cursor [Integer] the last video ID from the previous iteration
    # @param limit [Integer] the number of entries per iteration
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

      response = build_response(http_response)
      return [] if response.error?

      collection = response.data
      return [] if collection.nil? || !collection.is_a?(Array)

      Likee::CommentMapping.map_collection(collection)
    end

    private

    attr_reader :transport, :config

    def build_response(http_response)
      code = http_response.body['code']
      data = http_response.body['data']

      LikeeResponse.new(code:, data:)
    end
  end
end
