# ::ExchangeWrapper::Gdax::PublicApi
module ExchangeWrapper
  module Gdax
    class PublicApi

      class << self

        def currencies(key, secret, passphrase, params = {})
          ::ExchangeWrapper::Gdax::Base.request(
            key,
            secret,
            passphrase,
            :currencies,
            params
          )
        end

        def daily_stats(key, secret, passphrase, params = {})
          ::ExchangeWrapper::Gdax::Base.request(
            key,
            secret,
            passphrase,
            :daily_stats,
            params
          )
        end

        def last_trade(key, secret, passphrase, params = {})
          ::ExchangeWrapper::Gdax::Base.request(
            key,
            secret,
            passphrase,
            :last_trade,
            params
          )
        end

        def products(key, secret, passphrase, params = {})
          ::ExchangeWrapper::Gdax::Base.request(
            key,
            secret,
            passphrase,
            :products,
            params
          )
        end

        def price_history(key, secret, passphrase, params = {})
          ::ExchangeWrapper::Gdax::Base.request(
            key,
            secret,
            passphrase,
            :price_history,
            params
          )
        end

      end
    end
  end
end
