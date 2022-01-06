# frozen_string_literal: true

require_relative 'content_type'

module Likee
  class Transport
    class Response
      attr_reader :status, :body

      def self.from_net_http(net_http_response)
        status = net_http_response.code
        body = net_http_response.body
        content_type = net_http_response['Content-Type']

        new(status:, body:, content_type:)
      end

      def initialize(status:, body:, content_type:)
        content_type, charset = parse_content_type_header(content_type)

        body = ensure_utf8_encode(body, original_encode: charset) if charset
        body = content_type.load(body) if content_type

        @status = Integer(status)
        @body = body
        freeze
      end

      def success?
        status.between?(200, 299)
      end

      private

      def parse_content_type_header(header)
        return unless header

        mime_type = header.split(';').first
        return unless mime_type

        content_type = ContentType.find_by_mime_type(mime_type)
        charset = parse_charset_from_content_type(header)

        [content_type, charset]
      end

      def parse_charset_from_content_type(header)
        return unless header =~ /charset=([^;|$]+)/

        begin
          ::Encoding.find(Regexp.last_match(1))
        rescue StandardError
          nil
        end
      end

      def ensure_utf8_encode(body, original_encode: Encoding::UTF_8)
        body = body.dup if body.frozen?
        body
          .force_encoding(original_encode)
          .encode(Encoding::UTF_8)
          .freeze
      end
    end
  end
end
