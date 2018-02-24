# ::ExchangeWrapper::Binance::WithdrawApi
module ExchangeWrapper
  module Binance
    class WithdrawApi

      class << self

        def account_status(api_key, secret_key)
          request(
            :get,
            'v3/accountStatus.html',
            api_key,
            secret_key
          )
        end

        def deposit_history(api_key, secret_key)
          request(
            :get,
            'v3/depositHistory.html',
            api_key,
            secret_key
          )
        end

        def withdraw_history(api_key, secret_key)
          request(
            :get,
            'v3/withdrawHistory.html',
            api_key,
            secret_key
          )
        end

        private

        def request(method, url, api_key, secret_key, options = {})
          ::ExchangeWrapper::Binance::Base.withdraw_request(
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
