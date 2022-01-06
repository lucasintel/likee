# frozen_string_literal: true

require 'securerandom'

begin
  require 'oj'
rescue LoadError
  require 'json'
end

module Likee
  module Util
    class << self
      def dump_json(hash)
        if Object.const_defined?(:Oj)
          Oj.dump(hash, mode: :compat)
        else
          hash.to_json
        end
      end

      def load_json(payload)
        if Object.const_defined?(:Oj)
          Oj.load(payload, mode: :compat)
        else
          JSON.parse(payload)
        end
      end

      def monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def random_device_id
        SecureRandom.uuid.delete('-')
      end

      def random_user_id(length = 10)
        Array.new(length) { Random.rand(1..9) }.join.to_i
      end

      def object_identity(object)
        "#{object.class.name}(0x#{object_id.to_s(16)})"
      end
    end
  end
end
