# frozen_string_literal: true

require_relative 'resource_collection'
require_relative 'comment_resource'

module Likee
  class CommentResourceCollection < ResourceCollection
    def resource_class
      CommentResource
    end

    def fetch_resource(cursor:)
      api.video_comments(video_id: video.id, cursor:)
    end

    def video
      parent
    end
  end
end
