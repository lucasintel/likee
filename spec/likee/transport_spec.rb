# frozen_string_literal: true

RSpec.describe Likee::Transport do
  let(:config) { build(:config) }

  subject { described_class.new(config) }

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

  describe '#reload', skip: 'proxy rotation feature is not public yet' do
    it 'reloads the configuration and updates the cached connections' do
      request_with_original_referer =
        stub_request(:get, 'https://test.host/videos')
        .with(
          headers: {
            'Referer' => 'https://likee.video/'
          }
        )

      subject.get(endpoint: 'https://test.host/videos')

      config.referer = 'https://google.com'
      subject.reload

      request_with_new_referer =
        stub_request(:get, 'https://test.host/videos')
        .with(
          headers: {
            'Referer' => 'https://google.com/'
          }
        )

      subject.get(endpoint: 'https://test.host/videos')

      expect(request_with_original_referer).to have_been_requested
      expect(request_with_new_referer).to have_been_requested
    end
  end

  describe '#reload' do
    it 'reloads the configuration' do
      expect(subject.reload).to be_truthy
    end
  end

  describe 'proxy' do
    let(:config) { build(:config, proxy: 'http://user:pass@example.com') }

    it 'loads the proxy from the configuration' do
      expected_request = stub_request(:get, 'https://test.host/videos')

      subject.get(endpoint: 'https://test.host/videos')

      expect(expected_request).to have_been_requested
    end
  end

  describe 'response content type' do
    context 'when response has a known Content-Type header' do
      it 'parses the body' do
        stub_request(:get, 'https://test.host/videos')
          .to_return(
            body: '{"username":"@Likee_Russia"}',
            headers: {
              'Content-Type' => 'application/json;charset=UTF-8'
            }
          )

        response = subject.get(endpoint: 'https://test.host/videos')

        expect(response.body).to eq({ 'username' => '@Likee_Russia' })
      end
    end

    context 'when response has a unknown Content-Type header' do
      it 'does not parses the body' do
        stub_request(:get, 'https://test.host/videos')
          .to_return(
            body: '{"username":"@Likee_Russia"}',
            headers: {
              'Content-Type' => 'unknown/unknown'
            }
          )

        response = subject.get(endpoint: 'https://test.host/videos')

        expect(response.body).to eq('{"username":"@Likee_Russia"}')
      end
    end

    context 'when response has no Content-Type header' do
      it 'does not parses the body' do
        stub_request(:get, 'https://test.host/videos')
          .to_return(
            body: '{"username":"@Likee_Russia"}'
          )

        response = subject.get(endpoint: 'https://test.host/videos')

        expect(response.body).to eq('{"username":"@Likee_Russia"}')
      end
    end
  end

  describe 'response encoding' do
    context 'when Content-Type has a known charset identifier' do
      context 'when encoding is not utf8' do
        it 'encodes the body to utf8' do
          stub_request(:get, 'https://test.host/videos')
            .to_return(
              body: 'returned body'.encode('ISO-8859-1'),
              headers: {
                'Content-Type' => 'text/html; charset=iso-8859-1'
              }
            )

          response = subject.get(endpoint: 'https://test.host/videos')

          expect(response.body.encoding.name).to eq('UTF-8')
        end
      end

      context 'when encoding is already utf8' do
        it 'does nothing' do
          stub_request(:get, 'https://test.host/videos')
            .to_return(
              body: 'returned body',
              headers: {
                'Content-Type' => 'text/html; charset=utf-8'
              }
            )

          response = subject.get(endpoint: 'https://test.host/videos')

          expect(response.body.encoding.name).to eq('UTF-8')
        end
      end
    end

    context 'when Content-Type has a invalid charset identifier' do
      it 'does nothing' do
        stub_request(:get, 'https://test.host/videos')
          .to_return(
            body: 'returned body',
            headers: {
              'Content-Type' => 'text/html; charset=xxx'
            }
          )

        response = subject.get(endpoint: 'https://test.host/videos')

        expect(response.body.encoding.name).to eq('UTF-8')
      end
    end

    context 'when response has no Content-Type header' do
      it 'does nothing' do
        stub_request(:get, 'https://test.host/videos').to_return(body: 'returned body')

        response = subject.get(endpoint: 'https://test.host/videos')

        expect(response.body.encoding.name).to eq('UTF-8')
      end
    end
  end

  describe 'instrumentation' do
    let(:instrumentation) { double(:instrumentation) }

    subject { described_class.new(config, instrumentation:) }

    before do
      allow(Likee::Util).to receive(:monotonic_time).and_return(0.000, 0.020)
    end

    it 'notifies when request is successful' do
      stub_request(:get, 'https://test.host/videos')
      expect(instrumentation)
        .to receive(:notify)
        .with(
          hash_including(
            duration: 20,
            http_status: 200,
            method: 'GET',
            url: 'https://test.host/videos',
            config:
          )
        )

      subject.get(endpoint: 'https://test.host/videos')
    end

    it 'notifies when a connection error occurs' do
      stub_request(:get, 'https://test.host/videos').to_timeout
      expect(instrumentation)
        .to receive(:notify)
        .with(
          hash_including(
            duration: 20,
            http_status: nil,
            method: 'GET',
            url: 'https://test.host/videos',
            config:,
            exception: instance_of(described_class::TimeoutError)
          )
        )

      begin
        subject.get(endpoint: 'https://test.host/videos')
      rescue described_class::TimeoutError
        nil
      end
    end
  end

  describe 'net/http/persistent exceptions' do
    it 'handles IOError' do
      stub_request(:get, 'https://test.host').to_raise(IOError)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (IOError)')
    end

    it 'handles EOFError' do
      stub_request(:get, 'https://test.host').to_raise(EOFError)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (EOFError)')
    end

    it 'handles Errno::EADDRNOTAVAIL' do
      stub_request(:get, 'https://test.host').to_raise(Errno::EADDRNOTAVAIL)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Errno::EADDRNOTAVAIL)')
    end

    it 'handles Errno::ECONNABORTED' do
      stub_request(:get, 'https://test.host').to_raise(Errno::ECONNABORTED)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Errno::ECONNABORTED)')
    end

    it 'handles Errno::ECONNREFUSED' do
      stub_request(:get, 'https://test.host').to_raise(Errno::ECONNREFUSED)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Errno::ECONNREFUSED)')
    end

    it 'handles Errno::ECONNRESET' do
      stub_request(:get, 'https://test.host').to_raise(Errno::ECONNRESET)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Errno::ECONNRESET)')
    end

    it 'handles Errno::EHOSTDOWN' do
      stub_request(:get, 'https://test.host').to_raise(Errno::EHOSTDOWN)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Errno::EHOSTDOWN)')
    end

    it 'handles Errno::EHOSTUNREACH' do
      stub_request(:get, 'https://test.host').to_raise(Errno::EHOSTUNREACH)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Errno::EHOSTUNREACH)')
    end

    it 'handles Errno::EINVAL' do
      stub_request(:get, 'https://test.host').to_raise(Errno::EINVAL)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Errno::EINVAL)')
    end

    it 'handles Errno::ENETUNREACH' do
      stub_request(:get, 'https://test.host').to_raise(Errno::ENETUNREACH)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Errno::ENETUNREACH)')
    end

    it 'handles Errno::EPIPE' do
      stub_request(:get, 'https://test.host').to_raise(Errno::EPIPE)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Errno::EPIPE)')
    end

    it 'handles Errno::ETIMEDOUT' do
      stub_request(:get, 'https://test.host').to_raise(Errno::ETIMEDOUT)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::TimeoutError, 'Unexpected low level network error. (Errno::ETIMEDOUT)')
    end

    it 'handles Net::Net::HTTP::Persistent::Error' do
      stub_request(:get, 'https://test.host').to_raise(Net::HTTP::Persistent::Error)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Net::HTTP::Persistent::Error)')
    end

    it 'handles Net::HTTPBadResponse' do
      stub_request(:get, 'https://test.host').to_raise(Net::HTTPBadResponse)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Net::HTTPBadResponse)')
    end

    it 'handles Net::HTTPHeaderSyntaxError' do
      stub_request(:get, 'https://test.host').to_raise(Net::HTTPHeaderSyntaxError)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Net::HTTPHeaderSyntaxError)')
    end

    it 'handles Net::OpenTimeout' do
      stub_request(:get, 'https://test.host').to_raise(Net::OpenTimeout)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::TimeoutError, 'Unexpected low level network error. (Net::OpenTimeout)')
    end

    it 'handles Net::ProtocolError' do
      stub_request(:get, 'https://test.host').to_raise(Net::ProtocolError)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (Net::ProtocolError)')
    end

    it 'handles Net::ReadTimeout' do
      stub_request(:get, 'https://test.host').to_raise(Net::ReadTimeout)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::TimeoutError, 'Unexpected low level network error. (Net::ReadTimeout)')
    end

    it 'handles Net::WriteTimeout' do
      stub_request(:get, 'https://test.host').to_raise(Net::WriteTimeout)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::TimeoutError, 'Unexpected low level network error. (Net::WriteTimeout)')
    end

    it 'handles OpenSSL::SSL::SSLError' do
      stub_request(:get, 'https://test.host').to_raise(OpenSSL::SSL::SSLError)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (OpenSSL::SSL::SSLError)')
    end

    it 'handles SocketError' do
      stub_request(:get, 'https://test.host').to_raise(SocketError)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ConnectionError, 'Unexpected low level network error. (SocketError)')
    end
  end

  describe 'http response exceptions' do
    it 'raises BadRequestError when status is 400 Bad Request' do
      stub_request(:get, 'https://test.host').to_return(status: 400)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::BadRequestError, 'The server responded with a status of 400')
    end

    it 'raises Unauthorized Error when status is 401 Unauthorized' do
      stub_request(:get, 'https://test.host').to_return(status: 401)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::UnauthorizedError, 'The server responded with a status of 401')
    end

    it 'raises Forbidden Error when status is 403 Forbidden' do
      stub_request(:get, 'https://test.host').to_return(status: 403)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ForbiddenError, 'The server responded with a status of 403')
    end

    it 'raises NotFoundError when status is 404 Not Found' do
      stub_request(:get, 'https://test.host').to_return(status: 404)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::NotFoundError, 'The server responded with a status of 404')
    end

    it 'raises ProxyAuthenticationRequired when status is 407 Proxy Authentication Required' do
      stub_request(:get, 'https://test.host').to_return(status: 407)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ProxyAuthenticationRequired, 'The server responded with a status of 407')
    end

    it 'raises UnprocessableEntityError when status is 422 Unprocessable Entity' do
      stub_request(:get, 'https://test.host').to_return(status: 422)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::UnprocessableEntityError, 'The server responded with a status of 422')
    end

    it 'raises ClientError when status is 415 Random Error' do
      stub_request(:get, 'https://test.host').to_return(status: 415)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ClientError, 'The server responded with a status of 415')
    end

    it 'raises ServerError when status is 500 Internal Server Error' do
      stub_request(:get, 'https://test.host').to_return(status: 500)
      expect { subject.get(endpoint: 'https://test.host') }
        .to raise_exception(described_class::ServerError, 'The server responded with a status of 500')
    end
  end
end
