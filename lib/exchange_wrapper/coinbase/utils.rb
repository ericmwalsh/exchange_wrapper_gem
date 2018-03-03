# ::ExchangeWrapper::Coinbase::Utils
# # https://developers.coinbase.com/api/v2?ruby
module ExchangeWrapper
  module Coinbase
    class Utils
      class << self

        def holdings(key, secret) # string, string
          raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
          holdings = {}
          ::ExchangeWrapper::Coinbase::AccountApi.accounts(
            key,
            secret
          ).each do |currency|
            amount = currency['balance']['amount'].to_f
            if amount > 0.0
              holdings[currency['currency']] = amount
            end
          end

          holdings
        end

      end
    end
  end
end
