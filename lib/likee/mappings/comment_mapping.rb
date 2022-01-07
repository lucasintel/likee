# frozen_string_literal: true

require_relative '../models/comment'
require_relative '../util'

module Likee
  class CommentMapping
    def self.call(data)
      new(data).call
    end

    def initialize(data)
      @data = data.freeze
    end

    def call
      Comment.new(
        id:,
        created_at:,
        user_id:,
        user_username:,
        user_nickname:,
        user_avatar_url:,
        content:,
        reply_user_id:,
        reply_user_nickname:,
        reply_content:,
        likes_count:
      )
    end

    private

    attr_reader :data

    def id
      Snowflake.new(data['commentId'])
    end

    def created_at
      Time.at(data['commentTime'].to_i)
    end

    def user_id
      data['uid']
    end

    def user_username
      data['userName']
    end

    def user_nickname
      data['nickName']
    end

    def user_avatar_url
      data['avatar']
    end

    def content
      content_data['txt']
    end

    def reply_user_id
      user_id = content_data['re_uid']
      return if user_id.nil? || Integer(user_id).zero?

      user_id.abs.to_s
    end

    def reply_user_nickname
      nickname = content_data['re_n']
      return if nickname.nil? || nickname.empty?

      nickname
    end

    def reply_content
      content = content_data['re_txt']
      return if content.nil? || content.empty?

      content
    end

    def content_data
      @content_data ||= Util.load_json(data['comMsg'])
    end

    def likes_count
      data['likeCount'].to_i
    end
  end
end
