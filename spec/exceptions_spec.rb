RSpec.describe Exceptions do
  describe 'Base Errors' do
    describe 'BaseError' do
      it 'has a message of "Bad Request" and 400 status' do
        expect { raise ::Exceptions::BaseError }.to raise_error do |error|
          expect(error.message).to eql('Bad Request')
          expect(error.status).to eql(400)
        end
      end
    end

    describe 'ApiInputError' do
      it 'has a message of "API Input Invalid" and 400 status' do
        expect { raise ::Exceptions::ApiInputError }.to raise_error do |error|
          expect(error.message).to eql('API Input Invalid')
          expect(error.status).to eql(400)
        end
      end
    end

    describe 'ApiRateLimitError' do
      it 'has a message of "API Rate Limit Reached" and 429 status' do
        expect { raise ::Exceptions::ApiRateLimitError }.to raise_error do |error|
          expect(error.message).to eql('API Rate Limit Reached')
          expect(error.status).to eql(429)
        end
      end
    end

    describe 'ApiServerError' do
      it 'has a message of "API Server Error" and 500 status' do
        expect { raise ::Exceptions::ApiServerError }.to raise_error do |error|
          expect(error.message).to eql('API Server Error')
          expect(error.status).to eql(500)
        end
      end
    end

    describe 'ApiUnknownError' do
      it 'has a message of "API Response Status Unknown" and 504 status' do
        expect { raise ::Exceptions::ApiUnknownError }.to raise_error do |error|
          expect(error.message).to eql('API Response Status Unknown')
          expect(error.status).to eql(504)
        end
      end
    end
  end

  describe 'Input Errors' do
    describe 'BinanceApiInputError' do
      let(:example_error) {
        {"code"=>-2014, "msg"=>"API-key format invalid."}
      }
      it 'bubbles up the message from the API and returns a 400 status' do
        expect {
          raise ::Exceptions::BinanceApiInputError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql('Binance Error // Code -2014: API-key format invalid.')
          expect(error.status).to eql(400)
          expect(error).to be_a(::Exceptions::ApiInputError)
        end
      end
    end

    describe 'BittrexApiInputError' do
      let(:example_error) {
        {"success"=>false, "message"=>"APIKEY_INVALID", "result"=>nil}
      }
      it 'bubbles up the message from the API and returns a 400 status' do
        expect {
          raise ::Exceptions::BittrexApiInputError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql('Bittrex Error // Message: APIKEY_INVALID')
          expect(error.status).to eql(400)
          expect(error).to be_a(::Exceptions::ApiInputError)
        end
      end
    end

    describe 'CoinbaseApiInputError' do
      let(:example_message) {
        'invalid signature'
      }
      let(:example_error) {
        Coinbase::Wallet::AuthenticationError.new(example_message)
      }
      it 'bubbles up the message from the API and returns a 400 status' do
        expect {
          raise ::Exceptions::CoinbaseApiInputError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql("Coinbase Error // Coinbase::Wallet::AuthenticationError: #{example_message}")
          expect(error.status).to eql(400)
          expect(error).to be_a(::Exceptions::ApiInputError)
        end
      end
    end

    describe 'GdaxApiInputError' do
      let(:example_message) {
        'invalid signature'
      }
      let(:example_error) {
        Coinbase::Exchange::NotAuthorizedError.new(example_message)
      }
      it 'bubbles up the message from the API and returns a 400 status' do
        expect {
          raise ::Exceptions::GdaxApiInputError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql("GDAX Error // Coinbase::Exchange::NotAuthorizedError: #{example_message}")
          expect(error.status).to eql(400)
          expect(error).to be_a(::Exceptions::ApiInputError)
        end
      end
    end
  end

  describe 'Rate Limit Errors' do
    describe 'BinanceApiRateLimitError' do
      let(:example_error) {
        {"code"=>-1003, "msg"=>"Too many requests."}
      }
      it 'bubbles up the message from the API and returns a 429 status' do
        expect {
          raise ::Exceptions::BinanceApiRateLimitError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql('Binance Error // Code -1003: Too many requests.')
          expect(error.status).to eql(429)
          expect(error).to be_a(::Exceptions::ApiRateLimitError)
        end
      end
    end

    describe 'BittrexApiRateLimitError' do
      let(:example_error) {
        {"success"=>false, "message"=>"EXAMPLE_RATE_LIMIT_MESSAGE", "result"=>nil}
      }
      it 'bubbles up the message from the API and returns a 429 status' do
        expect {
          raise ::Exceptions::BittrexApiRateLimitError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql('Bittrex Error // Message: EXAMPLE_RATE_LIMIT_MESSAGE')
          expect(error.status).to eql(429)
          expect(error).to be_a(::Exceptions::ApiRateLimitError)
        end
      end
    end

    describe 'CoinbaseApiRateLimitError' do
      let(:example_message) {
        'example rate limit message'
      }
      let(:example_error) {
        Coinbase::Wallet::RateLimitError.new(example_message)
      }
      it 'bubbles up the message from the API and returns a 429 status' do
        expect {
          raise ::Exceptions::CoinbaseApiRateLimitError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql("Coinbase Error // Coinbase::Wallet::RateLimitError: #{example_message}")
          expect(error.status).to eql(429)
          expect(error).to be_a(::Exceptions::ApiRateLimitError)
        end
      end
    end

    describe 'GdaxApiRateLimitError' do
      let(:example_message) {
        'example rate limit message'
      }
      let(:example_error) {
        Coinbase::Exchange::RateLimitError.new(example_message)
      }
      it 'bubbles up the message from the API and returns a 429 status' do
        expect {
          raise ::Exceptions::GdaxApiRateLimitError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql("GDAX Error // Coinbase::Exchange::RateLimitError: #{example_message}")
          expect(error.status).to eql(429)
          expect(error).to be_a(::Exceptions::ApiRateLimitError)
        end
      end
    end
  end

  describe 'API Server Errors' do
    describe 'BinanceApiServerError' do
      let(:example_error) {
        {"code"=>-1000, "msg"=>"An unknown error occured while processing the request."}
      }
      it 'bubbles up the message from the API and returns a 500 status' do
        expect {
          raise ::Exceptions::BinanceApiServerError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql('Binance Error // Code -1000: An unknown error occured while processing the request.')
          expect(error.status).to eql(500)
          expect(error).to be_a(::Exceptions::ApiServerError)
        end
      end
    end

    describe 'BittrexApiServerError' do
      let(:example_error) {
        {"success"=>false, "message"=>"EXAMPLE_SERVER_ERROR_MESSAGE", "result"=>nil}
      }
      it 'bubbles up the message from the API and returns a 500 status' do
        expect {
          raise ::Exceptions::BittrexApiServerError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql('Bittrex Error // Message: EXAMPLE_SERVER_ERROR_MESSAGE')
          expect(error.status).to eql(500)
          expect(error).to be_a(::Exceptions::ApiServerError)
        end
      end
    end

    describe 'CoinbaseApiServerError' do
      let(:example_message) {
        'example server error message'
      }
      let(:example_error) {
        Coinbase::Wallet::InternalServerError.new(example_message)
      }
      it 'bubbles up the message from the API and returns a 500 status' do
        expect {
          raise ::Exceptions::CoinbaseApiServerError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql("Coinbase Error // Coinbase::Wallet::InternalServerError: #{example_message}")
          expect(error.status).to eql(500)
          expect(error).to be_a(::Exceptions::ApiServerError)
        end
      end
    end

    describe 'GdaxApiServerError' do
      let(:example_message) {
        'example server error message'
      }
      let(:example_error) {
        Coinbase::Exchange::InternalServerError.new(example_message)
      }
      it 'bubbles up the message from the API and returns a 500 status' do
        expect {
          raise ::Exceptions::GdaxApiServerError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql("GDAX Error // Coinbase::Exchange::InternalServerError: #{example_message}")
          expect(error.status).to eql(500)
          expect(error).to be_a(::Exceptions::ApiServerError)
        end
      end
    end
  end

  describe 'Status Unknown Errors' do
    describe 'BinanceApiUnknownError' do
      let(:example_error) {
        {"code"=>-1006, "msg"=>"An unexpected response was received from the message bus. Execution status unknown."}
      }
      it 'bubbles up the message from the API and returns a 504 status' do
        expect {
          raise ::Exceptions::BinanceApiUnknownError, example_error
        }.to raise_error do |error|
          expect(error.message).to eql('Binance Error // Code -1006: An unexpected response was received from the message bus. Execution status unknown.')
          expect(error.status).to eql(504)
          expect(error).to be_a(::Exceptions::ApiUnknownError)
        end
      end
    end
  end

end
