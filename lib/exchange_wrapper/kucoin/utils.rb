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
            next if symbol_hash['coin'].nil?
            symbols << symbol_hash['coin']
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_prices.each do |tp_hash|
            base_asset = tp_hash['coinType']
            quote_asset = tp_hash['coinTypePair']
            next if base_asset.nil? || quote_asset.nil? || !tp_hash['trading']

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

          fetch_prices.each do |tp_hash|
            base_asset = tp_hash['coinType']
            quote_asset = tp_hash['coinTypePair']
            next if base_asset.nil? || quote_asset.nil? || !tp_hash['trading']
            next if tp_hash['lastDealPrice'].nil?

            prices << {
              'symbol' => "#{base_asset}/#{quote_asset}",
              'price' => tp_hash['lastDealPrice']
            }
          end

          prices
        end

        def metadata
          metadata = []

          fetch_prices.each do |tp_hash|
            base_asset = tp_hash['coinType']
            quote_asset = tp_hash['coinTypePair']
            next if base_asset.nil? || quote_asset.nil? || !tp_hash['trading']

            metadata << tp_hash.merge('symbol' => "#{base_asset}/#{quote_asset}")
          end

          metadata
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

        def fetch_prices
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/kucoin-public-api-get-markets', expires_in: 30.seconds) do
              ::ExchangeWrapper::Kucoin::PublicApi.trading_symbols_tick
            end
          else
            ::ExchangeWrapper::Kucoin::PublicApi.trading_symbols_tick
          end['data']
        end

      end
    end
  end
end
