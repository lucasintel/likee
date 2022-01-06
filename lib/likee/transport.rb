# frozen_string_literal: true

require 'net/http'
require_relative 'instrumentation'
require_relative 'util'

module Likee
  class Transport
    CONNECT_TIMEOUT_ERROR_MESSAGE =
      'Timed out trying to connect to Likee (Request: %<url>s). ' \
      "Please check your internet connection and Likee's service status. (%<error>s)"

    READ_TIMEOUT_ERROR_MESSAGE =
      'Timed out while reading data from Likee (Request: %<url>s). ' \
      "Please check your internet connection and Likee's service status. (%<error>s)"

    WRITE_TIMEOUT_ERROR_MESSAGE =
      'Timed out while sending data to Likee (Request: %<url>s). ' \
      "Please check your internet connection and Likee's service status. (%<error>s)"

    CONNECTION_ERROR_MESSAGE =
      'Unexpected error when trying to connect to Likee (Request: %<url>s). ' \
      'Please check your internet connection. (%<error>s)'

    SSL_ERROR_MESSAGE =
      'Could not establish a secure connection to Likee (Request: %<url>s). (%<error>s)'

    UNEXPECTED_READ_ERROR_MESSAGE =
      'Unexpected error while reading data from Likee (Request: %<url>s). ' \
      "Please check your internet connection and Likee's service status. (%<error>s)"

    class TransportError < StandardError; end

    class ConnectionError < TransportError
      attr_reader :wrapped_exception

      def initialize(message, wrapped_exception)
        super(message)
        @wrapped_exception = wrapped_exception
      end
    end

    class ApiError < TransportError; end

    # rubocop:disable Layout/HashAlignment
    NET_HTTP_EXCEPTIONS_MAP = {
      EOFError               => CONNECTION_ERROR_MESSAGE,
      Errno::EADDRNOTAVAIL   => CONNECTION_ERROR_MESSAGE,
      Errno::ECONNABORTED    => UNEXPECTED_READ_ERROR_MESSAGE,
      Errno::ECONNREFUSED    => CONNECTION_ERROR_MESSAGE,
      Errno::ECONNRESET      => UNEXPECTED_READ_ERROR_MESSAGE,
      Errno::EHOSTUNREACH    => CONNECTION_ERROR_MESSAGE,
      Errno::ENETUNREACH     => CONNECTION_ERROR_MESSAGE,
      Errno::EPIPE           => UNEXPECTED_READ_ERROR_MESSAGE,
      Errno::ETIMEDOUT       => CONNECT_TIMEOUT_ERROR_MESSAGE,
      Net::OpenTimeout       => CONNECT_TIMEOUT_ERROR_MESSAGE,
      Net::ReadTimeout       => READ_TIMEOUT_ERROR_MESSAGE,
      Net::WriteTimeout      => WRITE_TIMEOUT_ERROR_MESSAGE,
      OpenSSL::SSL::SSLError => SSL_ERROR_MESSAGE,
      SocketError            => CONNECTION_ERROR_MESSAGE
    }.freeze
    # rubocop:enable Layout/HashAlignment

    private_constant :CONNECT_TIMEOUT_ERROR_MESSAGE
    private_constant :READ_TIMEOUT_ERROR_MESSAGE
    private_constant :WRITE_TIMEOUT_ERROR_MESSAGE
    private_constant :CONNECTION_ERROR_MESSAGE
    private_constant :SSL_ERROR_MESSAGE
    private_constant :UNEXPECTED_READ_ERROR_MESSAGE

    private_constant :NET_HTTP_EXCEPTIONS_MAP

    class ConnectionRepository
      def initialize(config)
        @cached_connections = {}
        @config = config
      end

      def fetch(uri)
        get(uri) || push(uri)
      end

      def clear
        cached_connections.each do |http|
          http.finish
        rescue IOError
          next
        end
        cached_connections.clear
      end

      private

      attr_reader :cached_connections, :config

      def get(uri)
        cached_connections[build_connection_id(uri)]
      end

      def push(uri)
        cached_connections[build_connection_id(uri)] = build_connection(uri)
      end

      def build_connection(uri)
        proxy = config.proxy || ENV['HTTP_PROXY'] || ENV['http_proxy']
        http_driver =
          if proxy
            proxy_uri = URI.parse(proxy)
            Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
          else
            Net::HTTP
          end
        http = http_driver.new(uri.host, uri.port)
        http.open_timeout = config.open_timeout
        http.read_timeout = config.read_timeout
        http.write_timeout = config.write_timeout
        if uri.instance_of?(URI::HTTPS)
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.use_ssl = true
        end
        http.max_retries = 0
        http.keep_alive_timeout = config.keep_alive_timeout
        http
      end

      def build_connection_id(uri)
        {
          scheme: uri.scheme,
          host: uri.host,
          port: uri.port
        }
      end
    end

    private_constant :ConnectionRepository

    class Response
      attr_reader :http_code, :body

      def initialize(http_code:, body:)
        @http_code = Integer(http_code)
        @body = body
        freeze
      end
    end

    private_constant :Response

    def initialize(config, instrumentation: Likee::Instrumentation)
      @connection_repository = ConnectionRepository.new(config)
      @config = config
      @instrumentation = instrumentation
      freeze
    end

    def get(endpoint:, response_format: :plain, query_params: {})
      response = perform(method: :get, endpoint:, query_params:)
      raise_on_http_error!(response)

      body = ensure_utf8_encode(response.body)
      parsed_body = parse_response_body(body, response_format)

      Response.new(http_code: response.code, body: parsed_body)
    end

    def post(endpoint:, request_format: :plain, response_format: :plain, body: {})
      response = perform(method: :post, endpoint:, request_format:, body:)
      raise_on_http_error!(response)

      body = ensure_utf8_encode(response.body)
      parsed_body = parse_response_body(body, response_format)

      Response.new(http_code: response.code, body: parsed_body)
    end

    def clear_connections
      connection_repository.clear
    end

    private

    attr_reader :connection_repository, :config, :instrumentation

    def perform(method:, endpoint:, query_params: {}, request_format: :plain, body: nil)
      uri = build_uri(endpoint, query_params:)
      connection = connection_repository.fetch(uri)
      request = build_request(uri:, method:, request_format:, body:)

      request_start = Util.monotonic_time
      connection.start unless connection.started?
      response = connection.request(request)
      duration = compute_duration_ms(request_start)

      instrumentation.notify(duration:, http_status: Integer(response.code), method:, url: uri.to_s, config:)

      response
    rescue *NET_HTTP_EXCEPTIONS_MAP.keys => e
      duration = compute_duration_ms(request_start)

      message_template = NET_HTTP_EXCEPTIONS_MAP[e.class]
      message = format(message_template, url: endpoint, error: e.class.name)

      exception = ConnectionError.new(message, e)

      instrumentation.notify(duration:, http_status: nil, method:, url: uri.to_s, exception:, config:)

      raise exception
    end

    def build_uri(endpoint, query_params: {})
      uri = URI.parse(endpoint)
      uri.query = URI.encode_www_form(query_params) if query_params.any?
      uri
    end

    def build_request(uri:, method:, request_format:, body:)
      normalized_method = method.upcase
      request_has_body = !!body
      response_has_body = method != :head
      path = uri.request_uri
      headers = {
        'User-Agent' => config.user_agent,
        'Referer' => config.referer
      }
      request = Net::HTTPGenericRequest.new(normalized_method, request_has_body, response_has_body, path, headers)
      case request_format
      when :json
        request['Content-Type'] = 'application/json'
        request.body = Util.dump_json(body)
      when :form_data
        request.set_form_data(body)
      else
        request.body = body
      end
      request
    end

    def compute_duration_ms(request_start)
      request_end = Util.monotonic_time
      ((request_end - request_start) * 1000).to_i
    end

    def raise_on_http_error!(response)
      return if response.code == '200'

      raise ApiError, "The server responded with a status of #{response.code} (#{response.class})"
    end

    def ensure_utf8_encode(body)
      body = body.dup if body.frozen?
      body
        .force_encoding(Encoding::UTF_8)
        .encode(Encoding::UTF_8)
        .freeze
    end

    def parse_response_body(response_body, format)
      case format
      when :json
        Util.load_json(response_body)
      else
        response_body
      end
    end
  end
end
