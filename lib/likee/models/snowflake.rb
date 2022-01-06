# frozen_string_literal: true

require 'time'

module Likee
  class Snowflake
    include Comparable

    attr_reader :id, :timestamp

    def initialize(id)
      @id = id.is_a?(Integer) ? id : Integer(id)
      @timestamp = Time.at(@id >> 32)
      freeze
    end

    def <=>(other)
      id <=> other.id
    end

    def inspect
      "#<Likee::Snowflake @id=#{id} @timestamp=#{timestamp}>"
    end

    def to_i
      id
    end

    def to_s
      id.to_s
    end
  end
end
