# ::ExchangeWrapper::Coinbase::Base
module ExchangeWrapper
  module Coinbase
    class Base

      class << self

        private

        def request(key, secret, method, args = {})
          if requests_disabled?
            raise ::Exceptions::ApiRateLimitError
          else
            client(key,secret).__send__(method, args)
          end
        rescue ::Coinbase::Wallet::APIError => err
          case err.class.to_s
          when ::Coinbase::Wallet::AuthenticationError.to_s
            # 401
            # user side
            raise ::Exceptions::CoinbaseApiInputError.new(err)
          when ::Coinbase::Wallet::RateLimitError.to_s
            # 429
            disable_requests
            raise ::Exceptions::CoinbaseApiRateLimitError.new(err)
          when ::Coinbase::Wallet::InternalServerError.to_s,
              ::Coinbase::Wallet::ServiceUnavailableError.to_s
            # 500, 503
            # coinbase error
            raise ::Exceptions::CoinbaseApiServerError.new(err)
          else
            raise ::Exceptions::CoinbaseApiServerError.new(err)
          end
        end

        def disable_requests
          ::Rails.cache.fetch('coinbase-requests-disabled', expires_in: 3.minutes) do
            true
          end
        end

        def enable_requests
          ::Rails.cache.delete('coinbase-requests-disabled')
        end

        def requests_disabled?
          ::Rails.cache.read('coinbase-requests-disabled').present?
        end

        # defines a `send` method so must use reserved `__send__` instead
        def client(key, secret)
          ::Coinbase::Wallet::Client.new(
            api_key: key,
            api_secret: secret
          )
        end

      end
    end
  end
end
