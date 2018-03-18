# ::ExchangeWrapper::Kucoin::Utils
# https://kucoinapidocs.docs.apiary.io/
# https://python-kucoin.readthedocs.io/en/latest/index.html
module ExchangeWrapper
  module Kucoin
    class Utils
      class << self

        # def holdings(key, secret) # string, string
        #   raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
        #   holdings = {}
        #   ::ExchangeWrapper::Kucoin::AccountApi.balances(
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
            next unless symbol_hash['coin'].present?
            symbols << symbol_hash['coin']
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_metadata.each do |md_hash|
            trading_pairs << [
              md_hash['symbol'],
              md_hash['coinType'],
              md_hash['coinTypePair']
            ]
          end

          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        def prices
          prices = []

          fetch_metadata.each do |md_hash|
            next unless md_hash['lastDealPrice'].present?

            prices << {
              'symbol' => md_hash['symbol'],
              'price' => md_hash['lastDealPrice']
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
            next unless md_hash['vol'].present? && md_hash['volValue'].present?

            volume << {
              'symbol' => md_hash['symbol'],
              'base_volume' => md_hash['vol'],
              'quote_volume' => md_hash['volValue']
            }
          end

          volume
        end

        private

        def fetch_symbols
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/kucoin-public-api-get-currencies', expires_in: 30.seconds) do
              ::ExchangeWrapper::Kucoin::PublicApi.coins
            end
          else
            ::ExchangeWrapper::Kucoin::PublicApi.coins
          end['data']
        end

        def fetch_metadata
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/kucoin-public-api-get-markets', expires_in: 30.seconds) do
              ::ExchangeWrapper::Kucoin::PublicApi.trading_symbols_tick
            end
          else
            ::ExchangeWrapper::Kucoin::PublicApi.trading_symbols_tick
          end['data'].map do |md_hash|
            base_asset = md_hash['coinType']
            quote_asset = md_hash['coinTypePair']
            if base_asset.present? && quote_asset.present? && md_hash['trading']
              md_hash.merge('symbol' => "#{base_asset}/#{quote_asset}")
            else
              nil
            end
          end.compact
        end

      end
    end
  end
end
