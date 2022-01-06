# frozen_string_literal: true

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

    # rubocop:disable Layout/HashAlignment
    NET_HTTP_EXCEPTIONS_MAP = {
      EOFError                     => CONNECTION_ERROR_MESSAGE,
      Errno::EADDRNOTAVAIL         => CONNECTION_ERROR_MESSAGE,
      Errno::ECONNABORTED          => UNEXPECTED_READ_ERROR_MESSAGE,
      Errno::ECONNREFUSED          => CONNECTION_ERROR_MESSAGE,
      Errno::ECONNRESET            => UNEXPECTED_READ_ERROR_MESSAGE,
      Errno::EHOSTDOWN             => CONNECTION_ERROR_MESSAGE,
      Errno::EHOSTUNREACH          => CONNECTION_ERROR_MESSAGE,
      Errno::ENETUNREACH           => CONNECTION_ERROR_MESSAGE,
      Errno::EPIPE                 => UNEXPECTED_READ_ERROR_MESSAGE,
      Errno::ETIMEDOUT             => CONNECT_TIMEOUT_ERROR_MESSAGE,
      Net::HTTP::Persistent::Error => CONNECTION_ERROR_MESSAGE,
      Net::OpenTimeout             => CONNECT_TIMEOUT_ERROR_MESSAGE,
      Net::ReadTimeout             => READ_TIMEOUT_ERROR_MESSAGE,
      Net::WriteTimeout            => WRITE_TIMEOUT_ERROR_MESSAGE,
      OpenSSL::SSL::SSLError       => SSL_ERROR_MESSAGE,
      SocketError                  => CONNECTION_ERROR_MESSAGE
    }.freeze
    # rubocop:enable Layout/HashAlignment

    ####
    ## Low level network errors
    ##

    class TransportError < StandardError; end

    class ConnectionError < TransportError
      attr_reader :wrapped_exception

      def initialize(message, wrapped_exception)
        super(message)
        @wrapped_exception = wrapped_exception
      end
    end

    ####
    ## HTTP errors
    ##

    class HTTPError < TransportError
      attr_reader :response

      def initialize(message, response)
        super(message)
        @response = response
      end
    end

    class ServerError < HTTPError; end

    class ClientError < HTTPError; end

    class BadRequestError < HTTPError; end

    class UnauthorizedError < HTTPError; end

    class ForbiddenError < HTTPError; end

    class NotFoundError < HTTPError; end

    class ProxyAuthenticationRequired < HTTPError; end

    class UnprocessableEntityError < HTTPError; end

    module ExceptionManager
      def self.net_http_exceptions
        NET_HTTP_EXCEPTIONS_MAP.keys
      end

      def self.message_from_net_http_exception(exception)
        NET_HTTP_EXCEPTIONS_MAP[exception.class]
      end

      def self.raise_from_response(response)
        message = "The server responded with a status of #{response.status}"
        exception_class =
          case response.status
          when 400 then BadRequestError
          when 401 then UnauthorizedError
          when 403 then ForbiddenError
          when 404 then NotFoundError
          when 407 then ProxyAuthenticationRequired
          when 422 then UnprocessableEntityError
          when 400..499
            ClientError
          else
            ServerError
          end

        raise exception_class.new(message, response)
      end
    end
  end
end
