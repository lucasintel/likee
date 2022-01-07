# frozen_string_literal: true

FactoryBot.define do
  factory :config, class: Likee::Configuration do
    user_agent { 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)' }
    referer { 'https://likee.video/' }
    custom_device_id { nil }
    custom_user_id { nil }
    open_timeout { 5 }
    read_timeout { 5 }
    write_timeout { 5 }
    keep_alive_idle_timeout { 45 }
    proxy { nil }

    initialize_with do
      new(
        user_agent:,
        referer:,
        custom_device_id:,
        custom_user_id:,
        open_timeout:,
        read_timeout:,
        write_timeout:,
        keep_alive_idle_timeout:,
        proxy:
      )
    end
  end
end
