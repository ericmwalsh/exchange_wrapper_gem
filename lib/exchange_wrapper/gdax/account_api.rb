# ::ExchangeWrapper::Gdax::AccountApi
module ExchangeWrapper
  module Gdax
    class AccountApi

      class << self

        def accounts(key, secret, passphrase)
          ::ExchangeWrapper::Gdax::Base.request(
            key,
            secret,
            passphrase,
            :accounts
          )
        end

      end
    end
  end
end
