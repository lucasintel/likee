# frozen_string_literal: true

module Likee
  Creator = Struct.new(
    :id,
    :username,
    :nickname,
    :avatar_url,
    :country,
    :gender,
    :birthday,
    :star_sign,
    :bio,
    :likes_count,
    :fans_count,
    :following_count,
    keyword_init: true
  )
end
