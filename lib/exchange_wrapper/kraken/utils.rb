# ::ExchangeWrapper::Kraken::Utils
# https://www.kraken.com/help/api
module ExchangeWrapper
  module Kraken
    class Utils
      class << self

        # def holdings(key, secret) # string, string
        #   raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
        #   holdings = {}
        #   ::ExchangeWrapper::Kraken::AccountApi.balances(
        #     key,
        #     secret
        #   ).each do |currency|
        #     amount = currency['available'].to_f
        #     if amount > 0.0 && !currency['currency'].nil?
        #       holdings[currency['currency']] = amount
        #     end
        #   end

        #   holdings
        # end

        def symbols
          symbols = []

          fetch_symbols.values.each do |symbol_hash|
            next if symbol_hash['altname'].nil?
            symbols << symbol_hash['altname']
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []
          symbols_map = fetch_symbols

          fetch_trading_pairs.each do |symbol, symbol_hash|
            next if symbol.nil? || symbol_hash['base'].nil? || symbol_hash['quote'].nil?
            base_asset = symbols_map[symbol_hash['base']]['altname']
            quote_asset = symbols_map[symbol_hash['quote']]['altname']
            next if base_asset.nil? || quote_asset.nil?

            trading_pairs << [
              "#{base_asset}/#{quote_asset}",
              base_asset,
              quote_asset
            ]
          end

          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        def prices
          prices = []

          fetch_metadata.each do |md_hash|
            next unless md_hash['c'][0].present?

            prices << {
              'symbol' => md_hash['symbol'],
              'price' => md_hash['c'][0]
            }
          end

          prices
        end

        def metadata
          fetch_metadata
        end

        def volume
          volume = []

          fetch_metadata.each do |md_hash|
            next unless md_hash['v'][1].present? && md_hash['p'][1].present?

            volume << {
              'symbol' => md_hash['symbol'],
              'base_volume' => md_hash['v'][1],
              'quote_volume' => md_hash['p'][1].to_f * md_hash['v'][1].to_f
            }
          end

          volume
        end

        private

        def fetch_symbols
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/kraken-public-api-symbols', expires_in: 30.seconds) do
              ::ExchangeWrapper::Kraken::PublicApi.symbols
            end
          else
            ::ExchangeWrapper::Kraken::PublicApi.symbols
          end['result']
        end

        def fetch_trading_pairs
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/kraken-public-api-trading-pairs', expires_in: 30.seconds) do
              ::ExchangeWrapper::Kraken::PublicApi.trading_pairs
            end
          else
            ::ExchangeWrapper::Kraken::PublicApi.trading_pairs
          end['result'].select {|symbol, symbol_hash| !symbol.include? '.d'} # skip .d tickers
        end

        def fetch_metadata
          metadata  = []

          symbols_map = fetch_symbols
          tps = fetch_trading_pairs
          symbols = tps.keys.join(',')

          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/kraken-public-api-tickers', expires_in: 30.seconds) do
              ::ExchangeWrapper::Kraken::PublicApi.ticker(symbols)
            end
          else
            ::ExchangeWrapper::Kraken::PublicApi.ticker(symbols)
          end['result'].each do |market, md_hash|
            next unless market.present?
            base_asset = symbols_map[tps[market]['base']]['altname']
            quote_asset = symbols_map[tps[market]['quote']]['altname']
            next unless base_asset.present? && quote_asset.present?

            metadata << md_hash.merge('symbol' => "#{base_asset}/#{quote_asset}")
          end

          metadata
        end

      end
    end
  end
end
