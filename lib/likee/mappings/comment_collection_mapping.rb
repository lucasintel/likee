# frozen_string_literal: true

require_relative 'comment_mapping'

module Likee
  class CommentCollectionMapping
    def self.call(data)
      new(data).call
    end

    def initialize(data)
      @data = data
      freeze
    end

    def call
      collection = data['data']
      return [] if collection.nil? || !collection.is_a?(Array)

      collection.map do |video_data|
        Likee::CommentMapping.(video_data)
      end
    end

    private

    attr_reader :data
  end
end
