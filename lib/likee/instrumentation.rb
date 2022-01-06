# frozen_string_literal: true

require_relative 'util'

module Likee
  class Instrumentation
    class Event
      attr_reader :duration, :http_status, :method, :url, :exception, :config

      def initialize(duration:, http_status:, method:, url:, config:, exception: nil)
        @duration = duration
        @http_status = http_status
        @method = method
        @url = url
        @exception = exception
        @config = config
        freeze
      end
    end

    private_constant :Event

    class << self
      def subscribe(name = Util.random_device_id, &block)
        raise ArgumentError, '#subscribe expects a block' unless block

        subscribers[name] = block
        name
      end

      def unsubscribe(name)
        subscribers.delete(name)
      end

      def notify(duration:, http_status:, method:, url:, config:, exception: nil)
        event = Event.new(duration:, http_status:, method:, url:, exception:, config:)

        subscribers.each_value do |subscriber|
          subscriber.call(event)
        end
      end

      def clear
        subscribers.clear
      end

      def subscribers
        @subscribers ||= {}
      end
    end
  end
end
