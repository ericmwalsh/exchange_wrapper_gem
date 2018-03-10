# ::ExchangeWrapper::Poloniex::PublicApi
module ExchangeWrapper
  module Poloniex
    class PublicApi

      class << self

        def currencies
          request(
            :get,
            'public?command=returnCurrencies'
          )
        end

        def tickers
          request(
            :get,
            'public?command=returnTicker'
          )
        end

        private

        def request(method, url, options = {})
          ::ExchangeWrapper::Poloniex::Base.public_request(
            method,
            url,
            options
          )
        end

      end
    end
  end
end
