# ::ExchangeWrapper::Mercatox::Utils
# https://cex.io/cex-api
module ExchangeWrapper
  module Mercatox
    class Utils
      class << self

        # def holdings(key, secret) # string, string
        #   raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
        #   holdings = {}
        #   ::ExchangeWrapper::Mercatox::AccountApi.balances(
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

          fetch_prices.each do |tp, symbol_hash|
            next unless tp.present? && symbol_hash['isFrozen'] == "0"
            assets = tp.split('_')
            base_asset = assets[0]
            quote_asset = assets[1]

            symbols << base_asset if base_asset.present?
            symbols << quote_asset if quote_asset.present?
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_prices.each do |tp, symbol_hash|
            next unless tp.present? && symbol_hash['isFrozen'] == "0"
            assets = tp.split('_')
            base_asset = assets[0]
            quote_asset = assets[1]
            next unless base_asset.present? && quote_asset.present?

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

          fetch_prices.each do |tp, tp_hash|
            next unless tp.present? && tp_hash['isFrozen'] == "0" && tp_hash['last'].present?
            assets = tp.split('_')
            base_asset = assets[0]
            quote_asset = assets[1]
            next unless base_asset.present? && quote_asset.present?

            prices << {
              'symbol' => "#{assets[0]}/#{assets[1]}",
              'price' => tp_hash['last']
            }
          end

          prices
        end

        def metadata
          metadata = []

          fetch_prices.each do |tp, tp_hash|
            next unless tp.present? && tp_hash['isFrozen'] == "0"
            assets = tp.split('_')
            base_asset = assets[0]
            quote_asset = assets[1]
            next unless base_asset.present? && quote_asset.present?

            metadata << tp_hash.merge('symbol' => "#{assets[0]}/#{assets[1]}")
          end

          metadata
        end

        private

        def fetch_prices
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/mercatox-public-api-market', expires_in: 30.seconds) do
              ::ExchangeWrapper::Mercatox::PublicApi.market
            end
          else
            ::ExchangeWrapper::Mercatox::PublicApi.market
          end['pairs']
        end

      end
    end
  end
end
