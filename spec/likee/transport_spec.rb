# frozen_string_literal: true

RSpec.describe Likee::Transport do
  let(:mocked_instrumentation) { double(:instrumentation) }
  let(:config) do
    Likee::Configuration.new(
      user_agent: 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
      referer: 'https://likee.video/',
      custom_device_id: nil,
      custom_user_id: nil,
      open_timeout: 5,
      read_timeout: 5,
      write_timeout: 5,
      keep_alive_timeout: 30,
      proxy: nil
    )
  end

  before do
    allow(mocked_instrumentation).to receive(:notify)
  end

  subject { described_class.new(config, instrumentation: mocked_instrumentation) }

  describe '#get' do
    it 'without query params' do
      expected_request =
        stub_request(:get, 'https://test.host/videos')
        .with(
          headers: {
            'Referer' => 'https://likee.video/',
            'User-Agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
          }
        )
        .to_return(status: 200, body: '{}')

      response = subject.get(endpoint: 'https://test.host/videos')

      expect(expected_request).to have_been_requested
      expect(response.status).to eq(200)
      expect(response.body).to eq('{}')
    end

    it 'with query params' do
      expected_request =
        stub_request(:get, 'https://test.host/videos?page=1&per=10&q=term')
        .with(
          headers: {
            'Referer' => 'https://likee.video/',
            'User-Agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
          }
        )
        .to_return(status: 200, body: '{}')

      response = subject.get(endpoint: 'https://test.host/videos', query_params: { q: 'term', page: 1, per: 10 })

      expect(expected_request).to have_been_requested
      expect(response.status).to eq(200)
      expect(response.body).to eq('{}')
    end
  end

  describe '#post' do
    it 'with json body' do
      expected_request =
        stub_request(:post, 'https://test.host/videos')
        .with(
          body: '{"uid":"111"}',
          headers: {
            'Content-Type' => 'application/json',
            'Referer' => 'https://likee.video/',
            'User-Agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
          }
        )
        .to_return(status: 200, body: '{}')

      response = subject.post(endpoint: 'https://test.host/videos', request_format: :json, body: { uid: '111' })

      expect(expected_request).to have_been_requested
      expect(response.status).to eq(200)
      expect(response.body).to eq('{}')
    end

    it 'with form data' do
      expected_request =
        stub_request(:post, 'https://test.host/videos')
        .with(
          body: { uid: '111' },
          headers: {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Referer' => 'https://likee.video/',
            'User-Agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
          }
        )
        .to_return(status: 200, body: '{}')

      response = subject.post(endpoint: 'https://test.host/videos', request_format: :form_url_encoded, body: { uid: '111' })

      expect(expected_request).to have_been_requested
      expect(response.status).to eq(200)
      expect(response.body).to eq('{}')
    end

    it 'with plain body' do
      expected_request =
        stub_request(:post, 'https://test.host/videos')
        .with(
          body: '<xml></xml>',
          headers: {
            'Referer' => 'https://likee.video/',
            'User-Agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
          }
        )
        .to_return(status: 200, body: '{}')

      response = subject.post(endpoint: 'https://test.host/videos', body: '<xml></xml>')

      expect(expected_request).to have_been_requested
      expect(response.status).to eq(200)
      expect(response.body).to eq('{}')
    end
  end

  describe 'instrumentation' do
    let(:instrumentation) { double(:instrumentation) }

    subject { described_class.new(config, instrumentation:) }

    it 'notifies when request is successful' do
      expected_request =
        stub_request(:get, 'https://test.host/videos')
        .to_return(status: 200, body: '{}')

      expect(instrumentation)
        .to receive(:notify)
        .with(
          hash_including(
            duration: instance_of(Integer),
            http_status: 200,
            method: 'GET',
            url: 'https://test.host/videos',
            config:
          )
        )

      subject.get(endpoint: 'https://test.host/videos')

      expect(expected_request).to have_been_requested
    end

    it 'notifies when a connection error occurs' do
      expected_request = stub_request(:get, 'https://test.host/videos').to_timeout
      expect(instrumentation)
        .to receive(:notify)
        .with(
          hash_including(
            duration: instance_of(Integer),
            http_status: nil,
            method: 'GET',
            url: 'https://test.host/videos',
            config:
          )
        )

      begin
        subject.get(endpoint: 'https://test.host/videos')
      rescue described_class::ConnectionError
        nil
      end

      expect(expected_request).to have_been_requested
    end
  end

  describe 'unsucessful requests' do
    it 'raises BadRequestError when status is 400 Bad Request' do
      expected_request = stub_request(:get, 'https://test.host/videos').to_return(status: 400)
      expect { subject.get(endpoint: 'https://test.host/videos') }
        .to raise_exception(described_class::BadRequestError, 'The server responded with a status of 400')

      expect(expected_request).to have_been_requested
    end

    it 'raises Unauthorized Error when status is 401 Unauthorized' do
      expected_request = stub_request(:get, 'https://test.host/videos').to_return(status: 401)
      expect { subject.get(endpoint: 'https://test.host/videos') }
        .to raise_exception(described_class::UnauthorizedError, 'The server responded with a status of 401')

      expect(expected_request).to have_been_requested
    end

    it 'raises Forbidden Error when status is 403 Forbidden' do
      expected_request = stub_request(:get, 'https://test.host/videos').to_return(status: 403)
      expect { subject.get(endpoint: 'https://test.host/videos') }
        .to raise_exception(described_class::ForbiddenError, 'The server responded with a status of 403')

      expect(expected_request).to have_been_requested
    end

    it 'raises NotFoundError when status is 404 Not Found' do
      expected_request = stub_request(:get, 'https://test.host/videos').to_return(status: 404)
      expect { subject.get(endpoint: 'https://test.host/videos') }
        .to raise_exception(described_class::NotFoundError, 'The server responded with a status of 404')

      expect(expected_request).to have_been_requested
    end

    it 'raises ProxyAuthenticationRequired when status is 407 Proxy Authentication Required' do
      expected_request = stub_request(:get, 'https://test.host/videos').to_return(status: 407)
      expect { subject.get(endpoint: 'https://test.host/videos') }
        .to raise_exception(described_class::ProxyAuthenticationRequired, 'The server responded with a status of 407')

      expect(expected_request).to have_been_requested
    end

    it 'raises ClientError when status is 415 Random Error' do
      expected_request = stub_request(:get, 'https://test.host/videos').to_return(status: 415)
      expect { subject.get(endpoint: 'https://test.host/videos') }
        .to raise_exception(described_class::ClientError, 'The server responded with a status of 415')

      expect(expected_request).to have_been_requested
    end

    it 'raises ServerError when status is 500 Internal Server Error' do
      expected_request = stub_request(:get, 'https://test.host/videos').to_return(status: 500)
      expect { subject.get(endpoint: 'https://test.host/videos') }
        .to raise_exception(described_class::ServerError, 'The server responded with a status of 500')

      expect(expected_request).to have_been_requested
    end
  end

  describe 'net/http exceptions' do
    shared_examples 'handles net/http exceptions' do |exception, expected_exception_message|
      it "handles #{exception}" do
        stub_request(:get, 'https://test.host/videos').to_raise(exception)
        expect { subject.get(endpoint: 'https://test.host/videos') }
          .to raise_exception(described_class::ConnectionError, expected_exception_message)
      end
    end

    include_examples 'handles net/http exceptions', EOFError, 'Unexpected error when trying to connect to Likee (Request: https://test.host/videos). Please check your internet connection. (EOFError)'
    include_examples 'handles net/http exceptions', Errno::EADDRNOTAVAIL, 'Unexpected error when trying to connect to Likee (Request: https://test.host/videos). Please check your internet connection. (Errno::EADDRNOTAVAIL)'
    include_examples 'handles net/http exceptions', Errno::ECONNABORTED, "Unexpected error while reading data from Likee (Request: https://test.host/videos). Please check your internet connection and Likee's service status. (Errno::ECONNABORTED)"
    include_examples 'handles net/http exceptions', Errno::ECONNREFUSED, 'Unexpected error when trying to connect to Likee (Request: https://test.host/videos). Please check your internet connection. (Net::HTTP::Persistent::Error)'
    include_examples 'handles net/http exceptions', Errno::ECONNRESET, "Unexpected error while reading data from Likee (Request: https://test.host/videos). Please check your internet connection and Likee's service status. (Errno::ECONNRESET)"
    include_examples 'handles net/http exceptions', Errno::EHOSTDOWN, 'Unexpected error when trying to connect to Likee (Request: https://test.host/videos). Please check your internet connection. (Net::HTTP::Persistent::Error)'
    include_examples 'handles net/http exceptions', Errno::EHOSTUNREACH, 'Unexpected error when trying to connect to Likee (Request: https://test.host/videos). Please check your internet connection. (Errno::EHOSTUNREACH)'
    include_examples 'handles net/http exceptions', Errno::ENETUNREACH, 'Unexpected error when trying to connect to Likee (Request: https://test.host/videos). Please check your internet connection. (Errno::ENETUNREACH)'
    include_examples 'handles net/http exceptions', Errno::EPIPE, "Unexpected error while reading data from Likee (Request: https://test.host/videos). Please check your internet connection and Likee's service status. (Errno::EPIPE)"
    include_examples 'handles net/http exceptions', Errno::ETIMEDOUT, "Timed out trying to connect to Likee (Request: https://test.host/videos). Please check your internet connection and Likee's service status. (Errno::ETIMEDOUT)"
    include_examples 'handles net/http exceptions', Net::OpenTimeout, "Timed out trying to connect to Likee (Request: https://test.host/videos). Please check your internet connection and Likee's service status. (Net::OpenTimeout)"
    include_examples 'handles net/http exceptions', Net::OpenTimeout, "Timed out trying to connect to Likee (Request: https://test.host/videos). Please check your internet connection and Likee's service status. (Net::OpenTimeout)"
    include_examples 'handles net/http exceptions', Net::ReadTimeout, "Timed out while reading data from Likee (Request: https://test.host/videos). Please check your internet connection and Likee's service status. (Net::ReadTimeout)"
    include_examples 'handles net/http exceptions', Net::WriteTimeout, "Timed out while sending data to Likee (Request: https://test.host/videos). Please check your internet connection and Likee's service status. (Net::WriteTimeout)"
    include_examples 'handles net/http exceptions', OpenSSL::SSL::SSLError, 'Could not establish a secure connection to Likee (Request: https://test.host/videos). (OpenSSL::SSL::SSLError)'
    include_examples 'handles net/http exceptions', SocketError, 'Unexpected error when trying to connect to Likee (Request: https://test.host/videos). Please check your internet connection. (SocketError)'
  end
end
