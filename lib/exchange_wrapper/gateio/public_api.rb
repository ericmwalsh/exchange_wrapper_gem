# ::ExchangeWrapper::Gateio::PublicApi
module ExchangeWrapper
  module Gateio
    class PublicApi

      class << self

        DEFAULT_MARKET = 'USD'

        def pairs
          request(
            :get,
            '1/pairs'
          )
        end

        def tickers
          request(
            :get,
            '1/tickers'
          )
        end

        private

        def request(method, url, options = {})
          ::ExchangeWrapper::Gateio::Base.public_request(
            method,
            url,
            options
          )
        end

      end
    end
  end
end
