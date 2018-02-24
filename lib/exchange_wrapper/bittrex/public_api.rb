# ::ExchangeWrapper::Bittrex::PublicApi
module ExchangeWrapper
  module Bittrex
    class PublicApi

      class << self

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

        # def get_ticker
        #   request(
        #     :get,
        #     'public/getticker'
        #   )
        # end

        def get_market_summaries
          request(
            :get,
            'public/getmarketsummaries'
          )
        end

        # def get_market_summary
        #   request(
        #     :get,
        #     'public/getmarketsummary'
        #   )
        # end

        # def get_order_book
        #   request(
        #     :get,
        #     'public/getorderbook'
        #   )
        # end

        # def get_market_history
        #   request(
        #     :get,
        #     'public/getmarkethistory'
        #   )
        # end

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
