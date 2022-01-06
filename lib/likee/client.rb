# frozen_string_literal: true

require_relative 'resources/creator_resource'
require_relative 'resources/trending_videos_resource_collection'
require_relative 'api'

module Likee
  class Client
    # Instantiates a client used to easily interact with the Likee API.
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
    # @return [Likee::Client]
    def initialize(api_class: Likee::Api, **args)
      @api = api_class.new(**args)
      freeze
    end

    # Find a creator by username.
    #
    # @param username [String] the creator username
    # @return [Likee::CreatorResource]
    def find_creator(username)
      CreatorResource.find(username, api:)
    end

    # Explore trending videos from a given location.
    #
    # @param country [String] the target country code
    # @param language [String] the target language
    # @param start [Integer] the recommendation offset
    #
    # @return [Likee::TrendingVideosResourceCollection]
    def trending_videos(country: :US, language: :us, start: 0)
      TrendingVideosResourceCollection.new(country:, language:, start:, api:)
    end

    private

    attr_reader :api
  end
end
