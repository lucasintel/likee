# frozen_string_literal: true

require_relative 'resource'
require_relative 'video_resource_collection'

module Likee
  class CreatorResource < Resource
    def self.find(username, api:)
      resource = api.find_creator(username)
      new(api:, resource:)
    end

    def videos
      @videos ||= VideoResourceCollection.new(api:, parent: self)
    end
  end
end
