# frozen_string_literal: true

module Likee
  Video = Struct.new(
    :id,
    :uploaded_at,
    :creator_id,
    :creator_username,
    :creator_nickname,
    :creator_avatar_url,
    :title,
    :description,
    :height,
    :width,
    :thumbnail_url,
    :url,
    :sound_id,
    :sound_name,
    :sound_owner_name,
    :sound_thumbnail,
    :likes_count,
    :comments_count,
    :play_count,
    :share_count,
    :hashtags,
    :mentions,
    :country,
    keyword_init: true
  )

  Video::Hashtag = Struct.new(
    :id,
    :name,
    keyword_init: true
  )

  Video::Mention = Struct.new(
    :id,
    :name,
    keyword_init: true
  )
end
