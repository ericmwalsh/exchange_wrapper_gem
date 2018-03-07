# ::ExchangeWrapper::Gemini::PublicApi
module ExchangeWrapper
  module Gemini
    class PublicApi

      class << self

        DEFAULT_MARKET = 'btcusd'

        def symbols
          request(
            :get,
            'symbols'
          )
        end

        def ticker(market = DEFAULT_MARKET)
          request(
            :get,
            "pubticker/#{market}"
          )
        end

        private

        def request(method, url, options = {})
          ::ExchangeWrapper::Gemini::Base.public_request(
            method,
            url,
            options
          )
        end

      end
    end
  end
end
