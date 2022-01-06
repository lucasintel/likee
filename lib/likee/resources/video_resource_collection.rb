# frozen_string_literal: true

require_relative 'resource_collection'
require_relative 'video_resource'

module Likee
  class VideoResourceCollection < ResourceCollection
    def resource_class
      VideoResource
    end

    def fetch_resource(cursor:)
      api.creator_videos(creator_id: creator.id, cursor:)
    end

    def creator
      parent
    end
  end
end
