# frozen_string_literal: true

require 'net/http/persistent'

require_relative 'instrumentation'
require_relative 'transport/exception_manager'
require_relative 'transport/request'
require_relative 'transport/response'
require_relative 'util'

module Likee
  class Transport
    def initialize(config, instrumentation: Likee::Instrumentation)
      @connection = Net::HTTP::Persistent.new(name: Util.object_identity(self))
      @config = config
      @instrumentation = instrumentation
      configure_connection
      freeze
    end

    def get(endpoint:, query_params: {})
      request = Request.new(method: :get, endpoint:, query_params:)
      perform(request)
    end

    def post(endpoint:, request_format: :plain, body: {})
      request = Request.new(method: :post, endpoint:, request_format:, body:)
      perform(request)
    end

    def reload
      configue_connection
    end

    private

    attr_reader :connection, :config, :instrumentation

    def configure_connection
      ensure_implicit_retry_is_disabled
      configure_proxy
      configure_timeouts
      configure_default_headers
      configure_keep_alive
    end

    def ensure_implicit_retry_is_disabled
      connection.max_retries = 0
    end

    def configure_proxy
      if config.proxy
        connection.proxy = proxy
      else
        connection.proxy_from_env
      end
    end

    def configure_timeouts
      connection.open_timeout = config.open_timeout
      connection.read_timeout = config.read_timeout
      connection.write_timeout = config.write_timeout
    end

    def configure_default_headers
      connection.override_headers['User-Agent'] = config.user_agent
      connection.override_headers['Referer'] = config.referer
    end

    def configure_keep_alive
      connection.idle_timeout = 45
    end

    def perform(request)
      net_http_request = request.to_net_http
      request_start = Util.monotonic_time
      net_http_response = connection.request(request.uri, net_http_request)
      duration = compute_duration_ms(request_start)

      response = Response.from_net_http(net_http_response)

      instrumentation.notify(
        duration:,
        http_status: response.status,
        method: request.method,
        url: request.uri.to_s,
        config:
      )

      raise_on_http_error!(response)
      response
    rescue *ExceptionManager.net_http_exceptions => e
      duration = compute_duration_ms(request_start)

      message = ExceptionManager.message_from_net_http_exception(e) % { url: request.uri, error: e.class.name }
      exception = ConnectionError.new(message, e)

      instrumentation.notify(
        duration:,
        http_status: nil,
        method: request.method,
        url: request.uri.to_s,
        exception:,
        config:
      )

      raise exception
    end

    def compute_duration_ms(request_start)
      request_end = Util.monotonic_time
      duration = request_end - request_start
      (duration * 1000).to_i
    end

    def raise_on_http_error!(response)
      return if response.success?

      ExceptionManager.raise_from_response(response)
    end
  end
end
