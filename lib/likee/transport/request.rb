# frozen_string_literal: true

require_relative 'content_type'

module Likee
  class Transport
    class Request
      attr_reader :uri, :method, :request_content_type, :body

      def initialize(method:, endpoint:, query_params: {}, request_format: :plain, body: nil)
        @uri = build_uri(endpoint, query_params:)
        @method = normalize_method(method)
        @request_content_type = ContentType.find(request_format)
        @body = body
        freeze
      end

      def to_net_http
        request = Net::HTTPGenericRequest.new(method, request_has_body?, response_has_body?, path, headers)
        request.body = request_content_type.dump(body)
        request
      end

      private

      def build_uri(endpoint, query_params:)
        uri = URI.parse(endpoint)
        uri.query = URI.encode_www_form(query_params) if query_params.any?
        uri
      end

      def normalize_method(method)
        method.to_s.upcase
      end

      def request_has_body?
        !!body
      end

      def response_has_body?
        method != 'HEAD'
      end

      def path
        uri.request_uri
      end

      def headers
        {
          'Content-Type' => request_content_type.mime_type
        }
      end
    end
  end
end
