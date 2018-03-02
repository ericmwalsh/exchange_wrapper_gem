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
          symbols = []

          fetch_symbols.each do |symbol|
            next if symbol['symbol'] == '123456' # skip dummy symbol data

            symbols << symbol['baseAsset']
            symbols << symbol['quoteAsset']
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_symbols.each do |symbol|
            next if symbol['symbol'] == '123456' # skip dummy symbol data

            trading_pairs << [
              "#{symbol['baseAsset']}/#{symbol['quoteAsset']}",
              symbol['baseAsset'],
              symbol['quoteAsset']
            ]
          end
          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        def prices
          prices = ::ExchangeWrapper::Binance::PublicApi.prices.sort do |tp_0, tp_1|
            tp_0['symbol'] <=> tp_1['symbol']
          end
          # remap the symbols with a '/'
          # e.g. ETHBTC -> ETH/BTC
          map = trading_pairs_map
          prices.map! do |tp|
            if tp['symbol'] == '123456' # skip dummy symbol data
              nil
            else
              tp.merge!('symbol' => map[tp['symbol']])
              tp
            end
          end.compact!

          prices
        end

        private

        def trading_pairs_map
          trading_pairs_map = {}

          fetch_symbols.each do |symbol|
            next if symbol['symbol'] == '123456' # skip dummy symbol data

            trading_pairs_map[symbol['symbol']] = "#{symbol['baseAsset']}/#{symbol['quoteAsset']}"
          end

          trading_pairs_map
        end

        def fetch_symbols
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/binance-public-api-exchange-info', expires_in: 58.seconds) do
              ::ExchangeWrapper::Binance::PublicApi.exchange_info
            end
          else
            ::ExchangeWrapper::Binance::PublicApi.exchange_info
          end['symbols']
        end
      end
    end
  end
end
