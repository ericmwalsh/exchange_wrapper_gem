# ::ExchangeWrapper::Gdax::AccountApi
module ExchangeWrapper
  module Gdax
    class AccountApi < ::ExchangeWrapper::Gdax::Base

      class << self

        def accounts(key, secret, passphrase)
          request(key, secret, passphrase, :accounts)
        end

      end
    end
  end
end
