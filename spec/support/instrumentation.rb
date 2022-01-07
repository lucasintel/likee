# frozen_string_literal: true

RSpec.configure do |config|
  def reset_instrumentation
    Likee.instrumentation.clear
  end

  config.before(:suite) do
    reset_instrumentation
  end

  config.before(:each) do
    reset_instrumentation
  end
end
