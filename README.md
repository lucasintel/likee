# Likee

Zero dependencies library designed to provide a stable and straightforward
interface to the Likee API.

[![Test Coverage](https://api.codeclimate.com/v1/badges/25ef2b2e4eb6be569fa9/test_coverage)](https://codeclimate.com/github/kandayo/likee/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/25ef2b2e4eb6be569fa9/maintainability)](https://codeclimate.com/github/kandayo/likee/maintainability)
[![CI](https://github.com/kandayo/likee/actions/workflows/main.yml/badge.svg)](https://github.com/kandayo/likee/actions/workflows/main.yml)

---

## Quickstart

```rb
# frozen_string_literal: true

require 'likee'

# please refer to the documentation to find all available options
# the default options are sensible, however you might need a proxy depending
# on your use case
client = Likee.build_client(proxy: 'https://user:pass@example.com')

# 💃🏻 find a creator by username
creator = client.find_creator('charlidamelio')

# returns an enumerable, pagination is automatically handled
creator_most_liked_videos =
  creator.videos.select { |video| video.likes_count > 100_000 }.first(10)

creator_most_liked_videos.each do |video|
  # ❤️ see likes count
  puts video.likes_count
  # 💬 see comments count
  puts video.comments_count
  # ▶️ see play count
  puts video.play_count
  # 🔗 see share count
  puts video.share_count
  # 🎧 get song name, owner, et cetera
  puts video.song_name
  # #️⃣ get the hashtags
  puts video.hashtags
  # 🔔 get the mentioned users
  puts video.mentions
  # 🎥 get the video url
  puts video.url

  # check out Likee::Video class to see all available properties

  # 💬 see video comments
  # also returns an enumerable, pagination is automatically handled
  video.comments.each do |comment|
    puts comment.user_nickname
    puts comment.content
  end
end

trending_videos = client.trending_videos(country: 'US')
trending_videos.each do |video|
  # 💃🏻 get the creator profile
  creator = video.creator

  # 📈 see creator stats
  puts creator.likes_count
  puts creator.fans_count
  puts creator.following_count

  # see more videos from the creator
  # -- the client design is straightforward
  creator.videos.first(10).each do |creator_video|
    creator_video.comments.each do |comment|
      # resources can access their parents, the relationship is two-way
      # same in-memory objects
      assert_equal(comment.video.creator, creator)
    end
  end
end

# 🎄 lazy evaluation
client
  .trending_hashtags(country: 'RU')
  .lazy
  .select { |hashtag| hashtag.name.include?('рождество') }
  .reject { |hashtag| hashtag.videos_count < 100 }
  .first(5)

# 🔍 search users, hashtags and videos
client.search_user("charli d'amelio")
client.search_hashtag('#LikeeNewYear2022')
client.search_video('toosie slide')

# a low level api client is also available 🤘🏻
api = Likee.build_api(proxy: 'https://user:pass@example.com')

api.creator_videos(creator_id: '111', cursor: '69453454234234212', limit: 30)
```

## Instrumentation

Part of this library has been used in production for a long time. You're
expected to monitor the requests and be aware of proxy blocks and API breaking
changes, since the API is not official.

#### Event

 - `duration`: Request duration in milliseconds.
 - `http_status`: HTTP response code.
 - `method`: HTTP method.
 - `url`: Request URL.
 - `config`: Client configuration (headers, proxy, et cetera.)
 - `exception`: Exception in case of a network error.

#### Example

```rb
Likee.instrumentation.subscribe do |event|
  entry = LogStash::Event.new(
    proxy: event.config.proxy,
    duration: event.duration,
    http_status: event.http_status,
    method: event.method,
    url: event.url,
  )
  # do something
end
```

## Downloading videos

https://github.com/kandayo/likee-scraper

## Current state

More features might be made public in the future. For now, it is what it is.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'likee'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install likee

## Development

After checking out the repo, run `bundle install` to install dependencies.
Then, run `bundle exec rspec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/kandayo/likee.

## License

The library is available as open source under the terms of the [3-Clause BSD License](https://opensource.org/licenses/BSD-3-Clause).
