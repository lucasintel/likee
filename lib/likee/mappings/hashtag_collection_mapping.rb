# frozen_string_literal: true

require_relative 'hashtag_mapping'

module Likee
  class HashtagCollectionMapping
    def self.call(data)
      new(data).call
    end

    def initialize(data)
      @data = data
      freeze
    end

    def call
      collection = data.dig('data', 'eventList')
      return [] if collection.nil? || !collection.is_a?(Array)

      collection.map do |hashtag_data|
        Likee::HashtagMapping.(hashtag_data)
      end
    end

    private

    attr_reader :data
  end
end
