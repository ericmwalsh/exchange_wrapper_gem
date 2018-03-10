# ::ExchangeWrapper::Kucoin::PublicApi
module ExchangeWrapper
  module Kucoin
    class PublicApi

      class << self

        def coins
          request(
            :get,
            'market/open/coins'
          )
        end

        def trading_symbols_tick
          request(
            :get,
            'market/open/symbols'
          )
        end

        private

        def request(method, url, options = {})
          ::ExchangeWrapper::Kucoin::Base.public_request(
            method,
            url,
            options
          )
        end

      end
    end
  end
end
