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
            base_asset = symbol['baseAsset']
            quote_asset = symbol['quoteAsset']
            symbols['currencies'] << base_asset
            symbols['currencies'] << quote_asset

            symbols['trading_pairs'] << [
              symbol['symbol'],
              base_asset,
              quote_asset
            ]
          end

          symbols['currencies'].sort!.uniq!
          # sort by symbol
          symbols['trading_pairs'].sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          symbols
        end

        def prices
          prices = ::ExchangeWrapper::Binance::PublicApi.prices.sort do |tp_0, tp_1|
            tp_0['symbol'] <=> tp_1['symbol']
          end
          # remove dummy trading pair
          prices.delete_at(prices.index {|tp| tp['symbol'] == '123456'} || prices.length)

          prices
        end

      end
    end
  end
end
