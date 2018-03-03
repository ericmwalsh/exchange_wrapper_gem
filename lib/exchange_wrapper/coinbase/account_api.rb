# ::ExchangeWrapper::Coinbase::AccountApi
module ExchangeWrapper
  module Coinbase
    class AccountApi

      class << self

        def accounts(key, secret)
          ::ExchangeWrapper::Coinbase::Base.request(
            key,
            secret,
            :accounts
          )
        end

        def currencies(key, secret)
          ::ExchangeWrapper::Coinbase::Base.request(
            key,
            secret,
            :currencies
          )
        end

        def exchange_rates(key, secret)
          ::ExchangeWrapper::Coinbase::Base.request(
            key,
            secret,
            :exchange_rates
          )
        end

      end
    end
  end
end
