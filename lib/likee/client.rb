# frozen_string_literal: true

require_relative 'resources/creator_resource'
require_relative 'resources/trending_videos_resource_collection'
require_relative 'api'

module Likee
  class Client
    def initialize(api_class: Likee::Api, **args)
      @api = api_class.new(**args)
      freeze
    end

    # Finds creator by username.
    #
    # @param username [String] the creator username
    #
    # @return [Likee::CreatorResource]
    def find_creator(username)
      CreatorResource.find(username, api:)
    end

    # Returns the trending videos from a given location.
    #
    # @param country [String] the country two-letter code (alpha-2)
    # @param language [String] the two-letter language code
    # @param start [Integer]
    #
    # @return [Likee::TrendingVideosResourceCollection]
    def trending_videos(country: :US, language: :us, start: 0)
      TrendingVideosResourceCollection.new(country:, language:, start:, api:)
    end

    private

    attr_reader :api
  end
end
