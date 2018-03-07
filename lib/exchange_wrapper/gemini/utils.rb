# ::ExchangeWrapper::Gemini::Utils
# https://docs.gemini.com/rest-api/
module ExchangeWrapper
  module Gemini
    class Utils
      class << self

        def holdings(key, secret) # string, string
          raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
          holdings = {}
          ::ExchangeWrapper::Gemini::AccountApi.balances(
            key,
            secret
          ).each do |currency|
            amount = currency['available'].to_f
            if amount > 0.0 && !currency['currency'].nil?
              holdings[currency['currency']] = amount
            end
          end

          holdings
        end

        def symbols
          symbols = []

          fetch_tickers(fetch_symbols).each do |market|
            market_symbols = market['volume'].keys - ['timestamp']
            next if market_symbols.size == 0
            symbols << market_symbols[0]
            symbols << market_symbols[1]
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_tickers(fetch_symbols).each do |market|
            market_symbols = market['volume'].keys - ['timestamp']
            next if market_symbols.size == 0
            trading_pairs << [
              "#{market_symbols[0]}/#{market_symbols[1]}",
              market_symbols[0],
              market_symbols[1]
            ]
          end
          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        def prices
          prices = []

          fetch_tickers(fetch_symbols).each do |market|
            market_symbols = market['volume'].keys - ['timestamp']
            next if market_symbols.size == 0 || market['last'].nil?
            prices << {
              'symbol' => "#{market_symbols[0]}/#{market_symbols[1]}",
              'price' => market['last']
            }
          end

          prices
        end

        def metadata
          metadata = []

          fetch_tickers(fetch_symbols).each do |market|
            market_symbols = market['volume'].keys - ['timestamp']
            next if market_symbols.size == 0
            metadata << market.merge('symbol' => "#{market_symbols[0]}/#{market_symbols[1]}")
          end

          metadata
        end

        private

        def fetch_symbols
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gemini-public-api-symbols', expires_in: 58.seconds) do
              ::ExchangeWrapper::Gemini::PublicApi.symbols
            end
          else
            ::ExchangeWrapper::Gemini::PublicApi.symbols
          end
        end

        def fetch_tickers(symbols) # array of strings
          if defined?(::Rails)
            symbols.map do |symbol|
              if symbol.nil?
                nil
              else
                ::Rails.cache.fetch("ExchangeWrapper/gemini-public-api-ticker-#{symbol}", expires_in: 58.seconds) do
                  ::ExchangeWrapper::Gemini::PublicApi.ticker(symbol)
                end
              end
            end.compact
          else
            symbols.map do |symbol|
              if symbol.nil?
                nil
              else
                ::ExchangeWrapper::Gemini::PublicApi.ticker(symbol)
              end
            end.compact
          end
        end

      end
    end
  end
end
