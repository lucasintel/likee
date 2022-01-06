# frozen_string_literal: true

require_relative '../models/creator'

module Likee
  class CreatorMapping
    def self.map_collection(collection)
      collection.map { |data| new(data).call }
    end

    def self.call(data)
      new(data).call
    end

    def initialize(data)
      @data = data
      freeze
    end

    def call
      Creator.new(
        id:,
        username:,
        nickname:,
        avatar_url:,
        country:,
        gender:,
        birthday:,
        star_sign:,
        bio:,
        likes_count:,
        fans_count:,
        following_count:
      )
    end

    private

    attr_reader :data

    def id
      data['uid']
    end

    def username
      data['likeeId']
    end

    def nickname
      data['nick_name']
    end

    def avatar_url
      data['bigUrl']
    end

    def country
      data['exactCountryCode']
    end

    def gender
      case data['gender']
      when 0 then :male
      when 1 then :female
      else
        :unknown
      end
    end

    def birthday
      birthday_string = data['birthday']
      return unless birthday_string

      Date.parse(birthday_string)
    end

    def star_sign
      data['constellation']
    end

    def bio
      data['bio']
    end

    def likes_count
      data['allLikeCount']
    end

    def fans_count
      data['fansCount']
    end

    def following_count
      data['followCount']
    end
  end
end
