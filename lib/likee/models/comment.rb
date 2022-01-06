# frozen_string_literal: true

module Likee
  Comment = Struct.new(
    :id,
    :created_at,
    :user_id,
    :user_username,
    :user_nickname,
    :user_avatar_url,
    :content,
    :reply_user_id,
    :reply_user_nickname,
    :reply_content,
    :likes_count,
    keyword_init: true
  )
end
