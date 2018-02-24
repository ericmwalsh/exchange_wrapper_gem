# ::ExchangeWrapper::Coinbase::AccountApi
module ExchangeWrapper
  module Coinbase
    class AccountApi < ::ExchangeWrapper::Coinbase::Base

      class << self

        def accounts(key, secret)
          request(key, secret, :accounts)
        end

      end
    end
  end
end
