# frozen_string_literal: true

require_relative 'resource'
require_relative 'comment_resource_collection'
require_relative 'creator_resource'

module Likee
  class VideoResource < Resource
    def comments
      @comments ||= CommentResourceCollection.new(api:, parent: self)
    end

    def creator
      return parent unless parent.nil?

      @creator ||= fetch_creator
    end

    private

    def fetch_creator
      CreatorResource.find(resource.creator_username, api:)
    end
  end
end
