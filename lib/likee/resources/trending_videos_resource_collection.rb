# frozen_string_literal: true

require_relative 'resource_collection'
require_relative 'video_resource'

module Likee
  class TrendingVideosResourceCollection < ResourceCollection
    def initialize(country:, language:, start:, **args)
      super(**args)
      @country = country
      @language = language
      @start = start
    end

    def resource_class
      VideoResource
    end

    def fetch_resource(cursor:)
      api.trending_videos(country:, language:, start:, cursor:)
    end

    private

    attr_reader :country, :language, :start
  end
end
