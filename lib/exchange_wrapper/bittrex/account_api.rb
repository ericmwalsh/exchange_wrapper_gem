# ::ExchangeWrapper::Bittrex::AccountApi
module ExchangeWrapper
  module Bittrex
    class AccountApi

      class << self

        def get_balances(api_key, secret_key)
          request(
            :get,
            'account/getbalances',
            api_key,
            secret_key
          )
        end

        private

        def request(method, url, api_key, secret_key, options = {})
          ::ExchangeWrapper::Bittrex::Base.signed_request(
            method,
            url,
            api_key,
            secret_key,
            options
          )
        end

      end
    end
  end
end
