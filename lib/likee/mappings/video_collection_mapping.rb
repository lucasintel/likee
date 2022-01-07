# frozen_string_literal: true

require_relative 'video_mapping'

module Likee
  class VideoCollectionMapping
    def self.call(data)
      new(data).call
    end

    def initialize(data)
      @data = data
      freeze
    end

    def call
      collection = data.dig('data', 'videoList')
      return [] if collection.nil? || !collection.is_a?(Array)

      collection.map do |video_data|
        Likee::VideoMapping.(video_data)
      end
    end

    private

    attr_reader :data
  end
end
