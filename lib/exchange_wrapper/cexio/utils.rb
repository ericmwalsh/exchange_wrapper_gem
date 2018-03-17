# ::ExchangeWrapper::Cexio::Utils
# https://cex.io/cex-api
module ExchangeWrapper
  module Cexio
    class Utils
      class << self

        # def holdings(key, secret) # string, string
        #   raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
        #   holdings = {}
        #   ::ExchangeWrapper::Cexio::AccountApi.balances(
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

          fetch_symbols.each do |symbol_hash|
            next if symbol_hash['symbol1'].nil? || symbol_hash['symbol2'].nil?
            symbols << symbol_hash['symbol1']
            symbols << symbol_hash['symbol2']
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_metadata(symbols).each do |md_hash|
            assets = md_hash['pair'].split(':')

            trading_pairs << [
              "#{assets[0]}/#{assets[1]}",
              assets[0],
              assets[1]
            ]
          end

          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        def prices
          prices = []

          fetch_metadata(symbols).each do |md_hash|
            next unless md_hash['last'].present?

            prices << {
              'symbol' => md_hash['symbol'],
              'price' => md_hash['last']
            }
          end

          prices
        end

        def metadata
          fetch_metadata(symbols)
        end

        def volume
          volume = []

          fetch_metadata(symbols).each do |md_hash|
            # because no vwap is provided we must default to using the low price
            # safer to underestimate than to overestimate
            next unless md_hash['volume'].present? && md_hash['low'].present?

            volume << {
              'symbol' => md_hash['symbol'],
              'base_volume' => md_hash['volume'],
              'quote_volume' => md_hash['low'].to_f * md_hash['volume'].to_f
            }
          end

          volume
        end

        private

        def fetch_symbols
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/cexio-public-api-currency-limits', expires_in: 30.seconds) do
              ::ExchangeWrapper::Cexio::PublicApi.currency_limits
            end
          else
            ::ExchangeWrapper::Cexio::PublicApi.currency_limits
          end['data']['pairs']
        end

        def fetch_metadata(symbols) # array of strings
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/cexio-public-api-tickers', expires_in: 30.seconds) do
              ::ExchangeWrapper::Cexio::PublicApi.tickers(symbols)
            end
          else
            ::ExchangeWrapper::Cexio::PublicApi.tickers(symbols)
          end['data'].map do |md_hash|
            assets = md_hash['pair'].split(':')
            if md_hash['pair'].present? && assets[0].present? && assets[1].present?
              md_hash.merge('symbol' => "#{assets[0]}/#{assets[1]}")
            else
              nil
            end
          end.compact
        end

      end
    end
  end
end
