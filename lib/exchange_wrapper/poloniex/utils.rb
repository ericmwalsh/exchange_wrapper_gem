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
            next unless symbol.present? && s_hash['frozen'] == 0
            next unless s_hash['disabled'] == 0 && s_hash['delisted'] == 0

            symbols << symbol
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_metadata.each do |md_hash|
            assets = md_hash['symbol'].split('/')

            trading_pairs << [
              md_hash['symbol'],
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

          fetch_metadata.each do |md_hash|
            next unless md_hash['last'].present?

            prices << {
              'symbol' => md_hash['symbol'],
              'price' => md_hash['last']
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
            next unless md_hash['baseVolume'].present? && md_hash['quoteVolume'].present?
            # confusing... poloniex uses the opposite naming convention
            # so quote/base used for base/quote
            volume << {
              'symbol' => md_hash['symbol'],
              'base_volume' => md_hash['quoteVolume'],
              'quote_volume' => md_hash['baseVolume']
            }
          end

          volume
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

        def fetch_metadata
          metadata = []

          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/poloniex-public-api-tickers', expires_in: 30.seconds) do
              ::ExchangeWrapper::Poloniex::PublicApi.tickers
            end
          else
            ::ExchangeWrapper::Poloniex::PublicApi.tickers
          end.each do |symbol, md_hash|
            next unless symbol.present? && md_hash['isFrozen'] == "0"
            assets = symbol.to_s.split('_')
            next unless assets[0].present? && assets[1].present?

            metadata << md_hash.merge('symbol' => "#{assets[1]}/#{assets[0]}")
          end

          metadata
        end

      end
    end
  end
end
