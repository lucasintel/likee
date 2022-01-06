# frozen_string_literal: true

FactoryBot.define do
  factory :video, class: Likee::Video do
    sequence(:id, &:to_s)
    uploaded_at { Time.now }
    sequence(:creator_id, &:to_s)
    sequence(:creator_username) { |n| "user_#{n}" }
    creator_nickname { 'Creator Nickname' }
    creator_avatar_url { 'https://likee.video/no_avatar.png' }
    title { 'Title' }
    description { 'Description' }
    height { 111 }
    width { 222 }
    thumbnail_url { 'thumb.png' }
    url { 'video.mp4' }
    sound_id { 1 }
    sound_name { 'Rock' }
    sound_owner_name { 'Rock Singer' }
    sound_thumbnail { 'rock.png' }
    likes_count { 1_000_000 }
    comments_count { 11_000 }
    play_count { 1_000_000_000 }
    share_count { 200_000 }
    hashtags { [] }
    mentions { [] }
    country { 'RU' }
  end
end
