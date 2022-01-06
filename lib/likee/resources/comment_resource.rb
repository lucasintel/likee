# frozen_string_literal: true

require_relative 'resource'

module Likee
  class CommentResource < Resource
    def video
      parent
    end
  end
end
