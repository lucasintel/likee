# frozen_string_literal: true

module Likee
  Hashtag = Struct.new(
    :id,
    :name,
    :videos_count,
    :play_count,
    keyword_init: true
  )
end
