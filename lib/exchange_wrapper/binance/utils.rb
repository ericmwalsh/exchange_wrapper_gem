# ::ExchangeWrapper::Binance::Utils
# https://github.com/binance-exchange/binance-official-api-docs
module ExchangeWrapper
  module Binance
    class Utils
      class << self

        def holdings(key, secret) # string, string
          raise ::Exceptions::InvalidInputError unless key.present? && secret.present?
          holdings = {}
          ::ExchangeWrapper::Binance::AccountApi.account_info(
            key,
            secret
          )['balances'].each do |currency|
            amount = currency['free'].to_f
            if amount > 0.0 && currency['asset'].present?
              holdings[currency['asset']] = amount
            end
          end

          holdings
        end

        def symbols
          symbols = []

          fetch_symbols.each do |symbol|
            symbols << symbol['baseAsset']
            symbols << symbol['quoteAsset']
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_symbols.each do |symbol|
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
          # remap the symbols with a '/'
          # e.g. ETHBTC -> ETH/BTC
          prices = fetch_metadata
          map = trading_pairs_map

          prices.map! do |md|
            if md['lastPrice'].present?
              mapped_symbol = map[md['symbol']]
              if mapped_symbol.present?
                {
                  'symbol' => mapped_symbol,
                  'price' => md['lastPrice']
                }
              else
                nil
              end
            else
              nil
            end
          end.compact!

          prices
        end

        def metadata
          metadata = fetch_metadata
          map = trading_pairs_map

          metadata.map! do |md|
            mapped_symbol = map[md['symbol']]
            if mapped_symbol.present?
              md.merge!('symbol' => mapped_symbol)
            else
              nil
            end
          end.compact!

          metadata
        end

        def volume
          volume = fetch_metadata
          map = trading_pairs_map

          volume.map! do |md|
            if md['quoteVolume'].present? && md['volume'].present?
              mapped_symbol = map[md['symbol']]
              if mapped_symbol.present?
                {
                  'symbol' => mapped_symbol,
                  'base_volume' => md['volume'],
                  'quote_volume' => md['quoteVolume']
                }
              else
                nil
              end
            else
              nil
            end
          end.compact!

          volume
        end

        private

        def trading_pairs_map
          trading_pairs_map = {}

          fetch_symbols.each do |symbol|
            trading_pairs_map[symbol['symbol']] = "#{symbol['baseAsset']}/#{symbol['quoteAsset']}"
          end

          trading_pairs_map
        end

        def fetch_metadata
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/binance-public-api-day-pricing', expires_in: 30.seconds) do
              ::ExchangeWrapper::Binance::PublicApi.day_pricing
            end
          else
            ::ExchangeWrapper::Binance::PublicApi.day_pricing
          end.select do |md_hash|
            md_hash['symbol'].present? && md_hash['symbol'] != '123456' # skip dummy symbol data
          end
        end

        def fetch_symbols
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/binance-public-api-exchange-info', expires_in: 30.seconds) do
              ::ExchangeWrapper::Binance::PublicApi.exchange_info
            end
          else
            ::ExchangeWrapper::Binance::PublicApi.exchange_info
          end['symbols'].select do |symbol|
            if symbol['symbol'] == '123456' # skip dummy symbol data
              false
            elsif !symbol['symbol'].present?
              false
            elsif !symbol['baseAsset'].present? || !symbol['quoteAsset'].present?
              false
            else
              true
            end
          end
        end

      end
    end
  end
end
