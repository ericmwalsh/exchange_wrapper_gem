# ::ExchangeWrapper::Gemini::Utils
# https://docs.gemini.com/rest-api/
module ExchangeWrapper
  module Gemini
    class Utils
      class << self

        def holdings(key, secret) # string, string
          raise ::Exceptions::InvalidInputError unless key.present? && secret.present?
          holdings = {}
          ::ExchangeWrapper::Gemini::AccountApi.balances(
            key,
            secret
          ).each do |currency|
            amount = currency['available'].to_f
            if amount > 0.0 && currency['currency'].present?
              holdings[currency['currency']] = amount
            end
          end

          holdings
        end

        def symbols
          symbols = []

          fetch_metadata(fetch_symbols).each do |market|
            market_symbols = market['volume'].keys - ['timestamp']
            symbols << market_symbols[0]
            symbols << market_symbols[1]
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_metadata(fetch_symbols).each do |market|
            market_symbols = market['volume'].keys - ['timestamp']
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

          fetch_metadata(fetch_symbols).each do |market|
            next unless market['last'].present?
            prices << {
              'symbol' => market['symbol'],
              'price' => market['last']
            }
          end

          prices
        end

        def metadata
          fetch_metadata(fetch_symbols)
        end

        def volume
          volume = []

          fetch_metadata(fetch_symbols).each do |market|
            assets = market['symbol'].split('/')
            base_volume = market['volume'][assets[0]]
            quote_volume = market['volume'][assets[1]]
            next unless base_volume.present? && quote_volume.present?

            volume << {
              'symbol' => market['symbol'],
              'base_volume' => base_volume,
              'quote_volume' => quote_volume
            }
          end

          volume
        end

        private

        def fetch_symbols
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gemini-public-api-symbols', expires_in: 30.seconds) do
              ::ExchangeWrapper::Gemini::PublicApi.symbols
            end
          else
            ::ExchangeWrapper::Gemini::PublicApi.symbols
          end.select do |symbol|
            symbol.present?
          end
        end

        def fetch_metadata(symbols) # array of strings
          if defined?(::Rails)
            symbols.map do |symbol|
              ::Rails.cache.fetch("ExchangeWrapper/gemini-public-api-ticker-#{symbol}", expires_in: 30.seconds) do
                ::ExchangeWrapper::Gemini::PublicApi.ticker(symbol)
              end
            end
          else
            symbols.map do |symbol|
              ::ExchangeWrapper::Gemini::PublicApi.ticker(symbol)
            end
          end.map do |md_hash|
            if md_hash.present? && md_hash['volume'].present?
              market_symbols = md_hash['volume'].keys - ['timestamp']
              if market_symbols.size == 0
                nil
              else
                md_hash.merge('symbol' => "#{market_symbols[0]}/#{market_symbols[1]}")
              end
            else
              nil
            end
          end.compact
        end

      end
    end
  end
end
