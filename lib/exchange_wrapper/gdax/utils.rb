# ::ExchangeWrapper::Gdax::Utils
module ExchangeWrapper
  module Gdax
    class Utils
      class << self

        def holdings(key, secret, passphrase)
          holdings = {}
          ::ExchangeWrapper::Gdax::AccountApi.accounts(
            key,
            secret,
            passphrase
          ).each do |currency|
            amount = currency['available'].to_f
            if amount > 0.0
              holdings[currency['currency']] = amount
            end
          end

          holdings
        end

        def symbols(key, secret, passphrase)
          symbols = []

          ::ExchangeWrapper::Gdax::PublicApi.currencies(
            key,
            secret,
            passphrase
          ).each do |currency|
            next unless currency['status'] == 'online'
            symbols << currency['id']
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs(key, secret, passphrase)
          trading_pairs = []

          ::ExchangeWrapper::Gdax::PublicApi.products(
            key,
            secret,
            passphrase
          ).each do |product|
            next unless product['status'] == 'online'

            trading_pairs << [
              product['display_name'],
              product['base_currency'],
              product['quote_currency']
            ]
          end
          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        # prices

        private

        def fiat_currencies
          [
            'EUR',
            'GBP',
            'USD'
          ]
        end

      end
    end
  end
end
