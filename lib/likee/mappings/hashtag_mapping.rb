# frozen_string_literal: true

require_relative '../models/hashtag'

module Likee
  class HashtagMapping
    def self.call(data)
      new(data).call
    end

    def initialize(data)
      @data = data
      freeze
    end

    def call
      Hashtag.new(
        id:,
        name:,
        videos_count:,
        play_count:
      )
    end

    private

    attr_reader :data

    def id
      data['eventId']
    end

    def name
      data['tagName']
    end

    def videos_count
      data['postCnt'].to_i
    end

    def play_count
      data['playCnt'].to_i
    end
  end
end
