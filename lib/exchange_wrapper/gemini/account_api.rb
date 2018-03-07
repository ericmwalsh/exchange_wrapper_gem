# ::ExchangeWrapper::Gemini::AccountApi
module ExchangeWrapper
  module Gemini
    class AccountApi

      class << self

        def balances(api_key, secret_key)
          request(
            :post,
            'balances',
            api_key,
            secret_key
          )
        end

        private

        def request(method, url, api_key, secret_key, options = {})
          ::ExchangeWrapper::Gemini::Base.signed_request(
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
