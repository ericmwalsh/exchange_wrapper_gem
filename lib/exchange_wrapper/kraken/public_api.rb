# ::ExchangeWrapper::Kraken::PublicApi
module ExchangeWrapper
  module Kraken
    class PublicApi

      class << self

        DEFAULT_MARKET = 'ETHUSD'

        def symbols
          request(
            :get,
            'public/Assets'
          )
        end

        def trading_pairs
          request(
            :get,
            'public/AssetPairs'
          )
        end

        def ticker(market = DEFAULT_MARKET) # string (comma separated list)
          request(
            :get,
            'public/Ticker',
            {
              pair: market
            }
          )
        end

        private

        def request(method, url, options = {})
          ::ExchangeWrapper::Kraken::Base.public_request(
            method,
            url,
            options
          )
        end

      end
    end
  end
end
