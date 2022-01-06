# frozen_string_literal: true

require_relative 'likee/api'
require_relative 'likee/client'
require_relative 'likee/version'

module Likee
  class << self
    # Instantiates a low level API client used to interact with Likee.
    #
    # @param user_agent [String] the User-Agent header used by the library
    # @param referer [String] the Referer header used by the library
    # @param custom_device_id [String] optional, the library generates a random
    #   device ID for each request, however you might want to set a consistent
    #   one to improve recommendations
    # @param custom_user_id [String] optional, the library generates a random
    #   user ID for each request, however you might want to set a consistent one
    #   to improve recommendations
    # @param keep_alive_timeout [Integer] the Keep-Alive timeout
    # @param open_timeout [Integer]
    # @param read_timeout [Integer]
    # @param write_timeout [Integer]
    # @param proxy [String] optional, a string containing your proxy address
    #
    # @return [Likee::Api]
    def build_api(**args)
      Api.new(**args)
    end

    # Instantiates a client used to easily interact with the Likee API.
    #
    # @param user_agent [String] the User-Agent header used by the library
    # @param referer [String] the Referer header used by the library
    # @param custom_device_id [String] optional, the library generates a random
    #   device ID for each request, however you might want to set a consistent
    #   one to improve recommendations
    # @param custom_user_id [String] optional, the library generates a random
    #   user ID for each request, however you might want to set a consistent one
    #   to improve recommendations
    # @param keep_alive_timeout [Integer] the Keep-Alive timeout
    # @param open_timeout [Integer]
    # @param read_timeout [Integer]
    # @param write_timeout [Integer]
    # @param proxy [String] optional, a string containing your proxy address
    #
    # @return [Likee::Client]
    def build_client(**args)
      Client.new(**args)
    end

    def instrumentation
      Likee::Instrumentation
    end
  end
end
