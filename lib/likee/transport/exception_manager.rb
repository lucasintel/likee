# frozen_string_literal: true

module Likee
  class Transport
    class TransportError < StandardError
    end

    ####
    ## Low level network errors
    ##

    class ConnectionError < TransportError
    end

    class TimeoutError < ConnectionError
    end

    CONNECTION_ERROR_EXCEPTION_MESSAGE = 'Unexpected low level network error. (%<wrapped_exception_name>s)'

    # rubocop:disable Layout/HashAlignment
    NET_HTTP_EXCEPTIONS_MAP = {
      IOError                      => ConnectionError,
      EOFError                     => ConnectionError,
      Errno::EADDRNOTAVAIL         => ConnectionError,
      Errno::ECONNABORTED          => ConnectionError,
      Errno::ECONNREFUSED          => ConnectionError,
      Errno::ECONNRESET            => ConnectionError,
      Errno::EHOSTDOWN             => ConnectionError,
      Errno::EHOSTUNREACH          => ConnectionError,
      Errno::EINVAL                => ConnectionError,
      Errno::ENETUNREACH           => ConnectionError,
      Errno::EPIPE                 => ConnectionError,
      Errno::ETIMEDOUT             => TimeoutError,
      Net::HTTP::Persistent::Error => ConnectionError,
      Net::HTTPBadResponse         => ConnectionError,
      Net::HTTPHeaderSyntaxError   => ConnectionError,
      Net::OpenTimeout             => TimeoutError,
      Net::ProtocolError           => ConnectionError,
      Net::ReadTimeout             => TimeoutError,
      Net::WriteTimeout            => TimeoutError,
      OpenSSL::SSL::SSLError       => ConnectionError,
      SocketError                  => ConnectionError
    }.freeze
    # rubocop:enable Layout/HashAlignment

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

      def self.build_exception_from_net_http_exception(net_http_exception)
        net_http_exception_class =
          if net_http_exception.is_a?(Net::HTTP::Persistent::Error)
            case net_http_exception.message
            when /connection refused/
              Errno::ECONNREFUSED
            when /host down/
              Errno::EHOSTDOWN
            else
              net_http_exception.class
            end
          else
            net_http_exception.class
          end

        exception_class = NET_HTTP_EXCEPTIONS_MAP[net_http_exception_class]
        exception_message = CONNECTION_ERROR_EXCEPTION_MESSAGE % { wrapped_exception_name: net_http_exception_class }

        exception_class.new(exception_message)
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
