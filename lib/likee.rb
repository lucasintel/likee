# frozen_string_literal: true

require_relative 'likee/api'
require_relative 'likee/client'
require_relative 'likee/version'

module Likee
  class << self
    # Builds an instance of the Likee API client.
    #
    # @param user_agent [String] the User-Agent header used by the library
    #
    # @param referer [String] the Referer header used by the library
    #
    # @param custom_device_id [String] optional, the library automatically
    #   generates a random device ID for each request, however you might want
    #   to set a consistent one
    #
    # @param custom_user_id [String] optional, the library automatically
    #   generates a random user ID for each request, however you might want to
    #   set a consistent one
    #
    # @param keep_alive_idle_timeout [Integer] maximum time an unused connection
    #   can remain idle before being automatically closed. If a connection
    #   hasn't been used for this number of seconds it will automatically
    #   be reset upon the next use to avoid attempting to send to a closed
    #   connection
    #
    # @param open_timeout [Integer] number of seconds to wait for the
    #   connection to open
    #
    # @param read_timeout [Integer] number of seconds to wait for data
    #
    # @param write_timeout [Integer] number of seconds to wait for data to
    #   reach the service
    #
    # @param proxy [String] optional, a string containing your proxy address
    #
    # @return [Likee::Client]
    def build_client(**args)
      Likee::Client.new(**args)
    end

    # Builds an instance of the Likee API low level client.
    #
    # @param (see #clean)
    #
    # @return [Likee::Api]
    def build_api(**args)
      Likee::Api.new(**args)
    end

    def instrumentation
      Likee::Instrumentation
    end
  end
end
