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

        def symbols
          symbols = {
            'currencies' => [],
            'trading_pairs' => []
          }

          ::ExchangeWrapper::Binance::PublicApi.exchange_info['symbols'].each do |symbol|
            next if symbol['symbol'] == '123456' # skip dummy symbol data
            symbols['currencies'] << symbol['baseAsset']
            symbols['currencies'] << symbol['quoteAsset']
            symbols['trading_pairs'] << symbol['symbol']
          end

          symbols['currencies'].sort!.uniq!
          symbols['trading_pairs'].sort!.uniq!

          symbols
        end

      end
    end
  end
end
