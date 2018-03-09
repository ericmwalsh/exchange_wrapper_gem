# ::ExchangeWrapper::Cryptopia::PublicApi
module ExchangeWrapper
  module Cryptopia
    class PublicApi

      class << self

        DEFAULT_MARKET = 'ETHUSD'

        def get_currencies
          request(
            :get,
            'GetCurrencies'
          )
        end

        def get_trade_pairs
          request(
            :get,
            'GetTradePairs'
          )
        end

        def get_markets(market = nil) # string (comma separated list)
          request(
            :get,
            "GetMarkets#{market.nil? ? '' : "/#{market}"}"
          )
        end

        private

        def request(method, url, options = {})
          ::ExchangeWrapper::Cryptopia::Base.public_request(
            method,
            url,
            options
          )
        end

      end
    end
  end
end
