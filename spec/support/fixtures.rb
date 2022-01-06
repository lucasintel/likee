# frozen_string_literal: true

require 'oj'

module Fixture
  def load_fixture(fixture_name)
    Oj.load(load_fixture_raw(fixture_name))
  end

  def load_fixture_raw(fixture_name)
    fixture_path = File.join(File.dirname(__FILE__), '..', 'fixtures', "#{fixture_name}.json")
    File.read(fixture_path)
  end
end

RSpec.configure do |config|
  config.include Fixture
end
