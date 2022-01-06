# frozen_string_literal: true

require_relative 'resource'

module Likee
  class ResourceCollection < Resource
    include Enumerable

    def initialize(**args)
      super
      @cached_collection ||= {}
    end

    # @abstract Subclass is expected to implement #resource_class
    # @!method resource_class
    #   The resource wrapper class.

    # @abstract Subclass is expected to implement #fetch_resource
    # @!method fetch_resource(cursor:)
    #   The method used to fetch the resource through pagination

    def each(&)
      return to_enum(:each) unless block_given?

      cursor = 0
      loop do
        @cached_collection[cursor] ||= begin
          collection = fetch_resource(cursor:)
          collection.map do |resource|
            resource_class.new(api:, resource:, parent:)
          end
        end
        collection = @cached_collection[cursor]
        collection.freeze
        if collection.empty?
          @cached_collection.freeze
          break
        end
        cursor = collection.last.id
        collection.each(&)
      end
    end
  end
end
