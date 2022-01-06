# frozen_string_literal: true

require 'uri'
require_relative '../util'

module Likee
  module ContentType
    class Entry
      attr_reader :mime_type

      def initialize(mime_type:, serializer:, deserializer:)
        @mime_type = mime_type
        @serializer = serializer
        @deserializer = deserializer
      end

      def load(payload)
        @deserializer.call(payload)
      end

      def dump(data)
        @serializer.call(data)
      end
    end

    PASSTHROUGH_CONTENT_TYPE = ContentType::Entry.new(
      mime_type: nil,
      deserializer: ->(payload) { payload },
      serializer: ->(data) { data }
    )

    def self.find(name)
      types.fetch(name, PASSTHROUGH_CONTENT_TYPE)
    end

    def self.find_by_mime_type(mime_type)
      content_type = types.values.find { |entry| entry.mime_type == mime_type }

      content_type || PASSTHROUGH_CONTENT_TYPE
    end

    def self.register(name:, mime_type:, serializer:, deserializer:)
      types[name] = Entry.new(mime_type:, serializer:, deserializer:)
    end

    def self.types
      @types ||= {}
    end
  end
end

Likee::ContentType.register(
  name: :json,
  mime_type: 'application/json',
  deserializer: ->(payload) { Likee::Util.load_json(payload) },
  serializer: ->(data) { Likee::Util.dump_json(data) }
)

Likee::ContentType.register(
  name: :form_url_encoded,
  mime_type: 'application/x-www-form-urlencoded',
  deserializer: ->(payload) { URI_decode_www_form(payload) },
  serializer: ->(data) { URI.encode_www_form(data) }
)
