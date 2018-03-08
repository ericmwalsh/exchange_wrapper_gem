# ::ExchangeWrapper::Bitstamp::PublicApi
module ExchangeWrapper
  module Bitstamp
    class PublicApi

      class << self

        DEFAULT_MARKET = 'btcusd'

        def trading_pairs
          request(
            :get,
            'v2/trading-pairs-info/'
          )
        end

        def ticker(market = DEFAULT_MARKET)
          request(
            :get,
            "v2/ticker/#{market}/"
          )
        end

        private

        def request(method, url, options = {})
          ::ExchangeWrapper::Bitstamp::Base.public_request(
            method,
            url,
            options
          )
        end

      end
    end
  end
end
