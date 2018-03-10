# ::ExchangeWrapper::Mercatox::PublicApi
module ExchangeWrapper
  module Mercatox
    class PublicApi

      class << self

        DEFAULT_MARKET = 'USD'

        def market
          request(
            :get,
            'public/json24'
          )
        end

        private

        def request(method, url, options = {})
          ::ExchangeWrapper::Mercatox::Base.public_request(
            method,
            url,
            options
          )
        end

      end
    end
  end
end
