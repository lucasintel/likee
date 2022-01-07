# frozen_string_literal: true

require 'time'
require_relative '../models/snowflake'
require_relative '../models/video'
require_relative '../util'

module Likee
  class VideoMapping
    def self.call(data)
      new(data).call
    end

    def initialize(data)
      @data = data
      freeze
    end

    def call
      Video.new(
        id:,
        uploaded_at:,
        creator_id:,
        creator_username:,
        creator_nickname:,
        creator_avatar_url:,
        title:,
        description:,
        height:,
        width:,
        thumbnail_url:,
        url:,
        sound_id:,
        sound_name:,
        sound_owner_name:,
        sound_thumbnail:,
        likes_count:,
        comments_count:,
        play_count:,
        share_count:,
        hashtags:,
        mentions:,
        country:
      )
    end

    private

    attr_reader :data

    def id
      Snowflake.new(data['postId'])
    end

    def uploaded_at
      unix_timestamp = data['postTime']
      return if unix_timestamp.nil?

      Time.at(unix_timestamp)
    end

    def creator_id
      data['posterUid']
    end

    def creator_username
      data['likeeId']
    end

    def creator_nickname
      data['nickname']
    end

    def creator_avatar_url
      data['avatar']
    end

    def title
      data['title']
    end

    def description
      data['msgText']
    end

    def height
      data['videoHeight']
    end

    def width
      data['videoWidth']
    end

    def thumbnail_url
      data['coverUrl']
    end

    def url
      data['videoUrl']
    end

    def sound_id
      data.dig('sound', 'soundId') || data.dig('cloudMusic', 'musicId') || data['musicId']
    end

    def sound_name
      data.dig('sound', 'soundName') || data.dig('cloudMusic', 'musicName') || data['musicName']
    end

    def sound_owner_name
      data.dig('sound', 'ownerName')
    end

    def sound_thumbnail
      data.dig('sound', 'avatar') || data.dig('cloudMusic', 'avatar')
    end

    def likes_count
      data['likeCount']
    end

    def comments_count
      data['commentCount']
    end

    def play_count
      data['playCount']
    end

    def share_count
      data['shareCount']
    end

    def hashtags
      payload = data['hashtagInfos']
      return [] if payload.nil? || payload.empty?

      hashtags_data = Util.load_json(payload)
      hashtags_data.map do |tag|
        Video::Hashtag.new(id: tag['ev_id'].to_s, name: tag['hs_tg'])
      end
    end

    def mentions
      payload = data['atUserInfos']
      return [] if payload.nil? || payload.empty?

      mentions_data = Util.load_json(payload)
      mentions_data.map do |tag|
        Video::Mention.new(id: tag['uid'].to_s, name: tag['name'])
      end
    end

    def country
      data['country'] || data['videoCountry']
    end
  end
end
