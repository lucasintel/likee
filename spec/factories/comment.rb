# frozen_string_literal: true

FactoryBot.define do
  factory :comment, class: Likee::Comment do
    sequence(:id, &:to_s)
    created_at { Time.now }
    sequence(:user_id, &:to_s)
    sequence(:user_username) { |n| "user_#{n}" }
    user_nickname { 'Creator Nickname' }
    user_avatar_url { 'https://likee.video/no_avatar.png' }
    content { 'Content' }
    likes_count { 1_000_000 }
    sequence(:reply_user_id, &:to_s)
    reply_user_nickname { 'Reply User Nickname' }
    reply_content { 'Reply Content' }
  end
end
