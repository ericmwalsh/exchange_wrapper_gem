require 'coinbase/exchange'

require_relative 'account_api'
require_relative 'public_api'
require_relative 'utils'
require_relative 'websocket'
# ::ExchangeWrapper::Gdax::Base
module ExchangeWrapper
  module Gdax
    class Base

      class << self

        def request(key, secret, passphrase, method, args = {})
          if requests_disabled?
            raise ::Exceptions::ApiRateLimitError
          else
            client(key,secret, passphrase).send(method, args) do |resp|
              resp
            end
          end
        rescue ::Coinbase::Exchange::APIError => err
          case err.class.to_s
          when ::Coinbase::Exchange::BadRequestError.to_s
            # 400
            # user side
            raise ::Exceptions::GdaxApiInputError.new(err)
          when ::Coinbase::Exchange::RateLimitError.to_s
            # 429
            disable_requests
            raise ::Exceptions::GdaxApiRateLimitError.new(err)
          when ::Coinbase::Exchange::InternalServerError.to_s
            # 500
            # gdax error
            raise ::Exceptions::GdaxApiServerError.new(err)
          else
            raise ::Exceptions::GdaxApiServerError.new(err)
          end
        end

        def disable_requests
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gdax-requests-disabled', expires_in: 3.minutes) do
              true
            end
          end
        end

        def enable_requests
          if defined?(::Rails)
            ::Rails.cache.delete('ExchangeWrapper/gdax-requests-disabled')
          end
        end

        def requests_disabled?
          if defined?(::Rails)
            ::Rails.cache.read('ExchangeWrapper/gdax-requests-disabled').present?
          else
            false
          end
        end

        def client(key, secret, passphrase)
          ::Coinbase::Exchange::Client.new(key, secret, passphrase)
        end

      end
    end
  end
end
