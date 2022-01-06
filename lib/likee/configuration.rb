# frozen_string_literal: true

module Likee
  class Configuration
    attr_reader :user_agent, :referer, :custom_device_id, :custom_user_id, :open_timeout, :read_timeout,
                :write_timeout, :keep_alive_timeout, :proxy

    def initialize(
      user_agent:,
      referer:,
      custom_device_id:,
      custom_user_id:,
      open_timeout:,
      read_timeout:,
      write_timeout:,
      keep_alive_timeout:,
      proxy:
    )
      @user_agent = user_agent
      @referer = referer
      @custom_device_id = custom_device_id
      @custom_user_id = custom_user_id
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @write_timeout = write_timeout
      @keep_alive_timeout = keep_alive_timeout
      @proxy = proxy
      freeze
    end
  end
end
