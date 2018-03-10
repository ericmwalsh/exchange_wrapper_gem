# ::ExchangeWrapper::Cexio::PublicApi
module ExchangeWrapper
  module Cexio
    class PublicApi

      class << self

        DEFAULT_MARKET = 'USD'

        def currency_limits
          request(
            :get,
            'currency_limits'
          )
        end

        def tickers(symbols = [DEFAULT_MARKET]) # array of strings
          request(
            :get,
            "tickers/#{symbols.join('/')}"
          )
        end

        private

        def request(method, url, options = {})
          ::ExchangeWrapper::Cexio::Base.public_request(
            method,
            url,
            options
          )
        end

      end
    end
  end
end
