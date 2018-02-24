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

      end
    end
  end
end
