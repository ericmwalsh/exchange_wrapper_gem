require 'coinbase/wallet'

require_relative 'account_api'
require_relative 'utils'
# ::ExchangeWrapper::Coinbase::Base
module ExchangeWrapper
  module Coinbase
    class Base

      class << self

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
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/coinbase-requests-disabled', expires_in: 3.minutes) do
              true
            end
          end
        end

        def enable_requests
          if defined?(::Rails)
            ::Rails.cache.delete('ExchangeWrapper/coinbase-requests-disabled')
          end
        end

        def requests_disabled?
          if defined?(::Rails)
            ::Rails.cache.read('ExchangeWrapper/coinbase-requests-disabled').present?
          else
            false
          end
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
