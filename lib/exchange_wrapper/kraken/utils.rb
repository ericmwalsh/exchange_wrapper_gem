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
          symbols_map = fetch_symbols
          tps = fetch_trading_pairs
          tp_symbols = tps.keys.join(',')

          fetch_tickers(tp_symbols).each do |market, market_hash|
            next if market.nil? || market_hash['c'][0].nil?
            base_asset = symbols_map[tps[market]['base']]['altname']
            quote_asset = symbols_map[tps[market]['quote']]['altname']
            next if base_asset.nil? || quote_asset.nil?

            prices << {
              'symbol' => "#{base_asset}/#{quote_asset}",
              'price' => market_hash['c'][0]
            }
          end

          prices
        end

        def metadata
          metadata = []
          symbols_map = fetch_symbols
          tps = fetch_trading_pairs
          tp_symbols = tps.keys.join(',')

          fetch_tickers(tp_symbols).each do |market, market_hash|
            next if market.nil?
            base_asset = symbols_map[tps[market]['base']]['altname']
            quote_asset = symbols_map[tps[market]['quote']]['altname']
            next if base_asset.nil? || quote_asset.nil?

            metadata << market_hash.merge('symbol' => "#{base_asset}/#{quote_asset}")
          end

          metadata
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

        def fetch_tickers(symbols) # string, comma separated
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/kraken-public-api-tickers', expires_in: 30.seconds) do
              ::ExchangeWrapper::Kraken::PublicApi.ticker(symbols)
            end
          else
            ::ExchangeWrapper::Kraken::PublicApi.ticker(symbols)
          end['result']
        end

      end
    end
  end
end
