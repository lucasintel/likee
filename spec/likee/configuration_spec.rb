# frozen_string_literal: true

RSpec.describe Likee::Configuration do
  subject do
    described_class.new(
      user_agent: 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
      referer: 'https://likee.video/',
      custom_device_id: '111',
      custom_user_id: '222',
      open_timeout: 5,
      read_timeout: 5,
      write_timeout: 5,
      keep_alive_idle_timeout: 45,
      proxy: 'http://username:password@proxy.example.com'
    )
  end

  it 'reads the configuration' do
    expect(subject.user_agent).to eq('Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)')
    expect(subject.referer).to eq('https://likee.video/')
    expect(subject.custom_device_id).to eq('111')
    expect(subject.custom_user_id).to eq('222')
    expect(subject.open_timeout).to eq(5)
    expect(subject.read_timeout).to eq(5)
    expect(subject.write_timeout).to eq(5)
    expect(subject.keep_alive_idle_timeout).to eq(45)
    expect(subject.proxy).to eq('http://username:password@proxy.example.com')
  end
end
