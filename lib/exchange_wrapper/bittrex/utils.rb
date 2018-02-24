# ::ExchangeWrapper::Bittrex::Utils
module ExchangeWrapper
  module Bittrex
    class Utils
      class << self

        def holdings(key, secret)
          holdings = {}
          ::ExchangeWrapper::Bittrex::AccountApi.get_balances(
            key,
            secret
          )['result'].each do |currency|
            amount = currency['Available'].to_f
            if amount > 0.0
              holdings[currency['Currency']] = amount
            end
          end

          holdings
        end

      end
    end
  end
end
