# ::ExchangeWrapper::Poloniex::Utils
# https://poloniex.com/support/api/
module ExchangeWrapper
  module Poloniex
    class Utils
      class << self

        # def holdings(key, secret) # string, string
        #   raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
        #   holdings = {}
        #   ::ExchangeWrapper::Poloniex::AccountApi.balances(
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

          fetch_symbols.each do |symbol, s_hash|
            next if symbol.nil?
            next if s_hash['disabled'] != 0 || s_hash['delisted'] != 0 || s_hash['frozen'] != 0

            symbols << symbol
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_prices.each do |symbol, tp_hash|
            next if symbol.nil? || tp_hash['isFrozen'] != "0"
            assets = symbol.split('_')

            trading_pairs << [
              "#{assets[1]}/#{assets[0]}",
              assets[1],
              assets[0]
            ]
          end

          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        def prices
          prices = []

          fetch_prices.each do |symbol, tp_hash|
            next if symbol.nil? || tp_hash['last'].nil? || tp_hash['isFrozen'] != "0"
            assets = symbol.split('_')

            prices << {
              'symbol' => "#{assets[1]}/#{assets[0]}",
              'price' => tp_hash['last']
            }
          end

          prices
        end

        def metadata
          metadata = []

          fetch_prices.each do |symbol, tp_hash|
            next if symbol.nil? || tp_hash['isFrozen'] != "0"
            assets = symbol.split('_')

            metadata << tp_hash.merge('symbol' => "#{assets[1]}/#{assets[0]}")
          end

          metadata
        end

        private

        def fetch_symbols
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/poloniex-public-api-currencies', expires_in: 30.seconds) do
              ::ExchangeWrapper::Poloniex::PublicApi.currencies
            end
          else
            ::ExchangeWrapper::Poloniex::PublicApi.currencies
          end
        end

        def fetch_prices
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/poloniex-public-api-tickers', expires_in: 30.seconds) do
              ::ExchangeWrapper::Poloniex::PublicApi.tickers
            end
          else
            ::ExchangeWrapper::Poloniex::PublicApi.tickers
          end
        end

      end
    end
  end
end
