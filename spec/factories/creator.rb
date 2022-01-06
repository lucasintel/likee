# frozen_string_literal: true

FactoryBot.define do
  factory :creator, class: Likee::Creator do
    sequence(:id, &:to_s)
    sequence(:username) { |n| "user_#{n}" }
    nickname { 'Nickname' }
    avatar_url { 'https://likee.video/no_avatar.png' }
    country { 'RU' }
    gender { :male }
    birthday { Date.new(2022, 12, 31) }
    star_sign { 'Taurus' }
    bio { '' }
    likes_count { 100_000 }
    fans_count { 10_000 }
    following_count { 10 }
  end
end
