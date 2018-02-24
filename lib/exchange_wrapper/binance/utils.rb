# ::ExchangeWrapper::Binance::Utils
module ExchangeWrapper
  module Binance
    class Utils
      class << self

        def holdings(key, secret)
          holdings = {}
          ::ExchangeWrapper::Binance::AccountApi.account_info(
            key,
            secret
          )['balances'].each do |currency|
            amount = currency['free'].to_f
            if amount > 0.0
              holdings[currency['asset']] = amount
            end
          end

          holdings
        end

      end
    end
  end
end
