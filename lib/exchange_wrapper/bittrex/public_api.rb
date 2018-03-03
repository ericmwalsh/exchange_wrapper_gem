# ::ExchangeWrapper::Bittrex::PublicApi
module ExchangeWrapper
  module Bittrex
    class PublicApi

      class << self

        DEFAULT_MARKET = 'BTC-ETH'

        def get_markets
          request(
            :get,
            'public/getmarkets'
          )
        end

        def get_currencies
          request(
            :get,
            'public/getcurrencies'
          )
        end

        def get_ticker(market = DEFAULT_MARKET)
          request(
            :get,
            'public/getticker',
            {
              market: market
            }
          )
        end

        def get_market_summaries
          request(
            :get,
            'public/getmarketsummaries'
          )
        end

        def get_market_summary(market = DEFAULT_MARKET)
          request(
            :get,
            'public/getmarketsummary',
            {
              market: market
            }
          )
        end

        # def get_order_book
        #   request(
        #     :get,
        #     'public/getorderbook'
        #   )
        # end

        def get_market_history(market = DEFAULT_MARKET)
          request(
            :get,
            'public/getmarkethistory',
            {
              market: market
            }
          )
        end

        private

        def request(method, url, options = {})
          ::ExchangeWrapper::Bittrex::Base.public_request(
            method,
            url,
            options
          )
        end

      end
    end
  end
end
