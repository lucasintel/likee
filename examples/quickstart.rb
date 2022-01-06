# frozen_string_literal: true

require 'likee'

# please refer to the documentation to find all available options
# the default options are sensible, however you might need a proxy depending
# on your use case
client = Likee.build_client

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

  # the client design is straightforward
  creator.videos.first(10).each do |creator_video|
    creator_video.comments.each do |comment|
      # resources can consistently access its parents
      puts comment.video.creator == creator
    end
  end
end

client
  .trending_hashtags(country: 'US')
  .first(10)
  .flat_map do |hashtag|
    hashtag.videos.select { |v| v.user_username == 'charlidamelio' }
  end

# 🔍 search users, hashtags and videos
client.search_user("charli d'amelio")
client.search_hashtag('#LikeeNewYear2022')
client.search_video('toosie slide')

# alternatively, the low level api client is also available 🤘🏻
api = Likee.build_api

api.creator_videos(creator_id: '111', cursor: '69453454234234212', limit: 30)
