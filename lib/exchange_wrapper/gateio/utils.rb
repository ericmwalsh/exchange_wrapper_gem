# ::ExchangeWrapper::Gateio::Utils
# https://gate.io/api2
module ExchangeWrapper
  module Gateio
    class Utils
      class << self

        # def holdings(key, secret) # string, string
        #   raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
        #   holdings = {}
        #   ::ExchangeWrapper::Gateio::AccountApi.balances(
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

          fetch_trading_pairs.each do |tp|
            next unless tp.present?
            assets = tp.split('_')
            base_asset = assets[0].to_s.upcase
            quote_asset = assets[1].to_s.upcase

            symbols << base_asset if base_asset.present?
            symbols << quote_asset if quote_asset.present?
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_trading_pairs.each do |tp|
            next unless tp.present?
            assets = tp.split('_')
            base_asset = assets[0].to_s.upcase
            quote_asset = assets[1].to_s.upcase
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
            next unless tp.present? && tp_hash['last'].present?
            assets = tp.split('_')
            base_asset = assets[0].to_s.upcase
            quote_asset = assets[1].to_s.upcase
            next unless base_asset.present? && quote_asset.present?

            prices << {
              'symbol' => "#{base_asset}/#{quote_asset}",
              'price' => tp_hash['last']
            }
          end

          prices
        end

        def metadata
          metadata = []

          fetch_prices.each do |tp, tp_hash|
            next unless tp.present?
            assets = tp.split('_')
            base_asset = assets[0].to_s.upcase
            quote_asset = assets[1].to_s.upcase
            next unless base_asset.present? && quote_asset.present?

            metadata << tp_hash.merge('symbol' => "#{base_asset}/#{quote_asset}")
          end

          metadata
        end

        private

        def fetch_trading_pairs
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gateio-public-api-pairs', expires_in: 30.seconds) do
              ::ExchangeWrapper::Gateio::PublicApi.pairs
            end
          else
            ::ExchangeWrapper::Gateio::PublicApi.pairs
          end
        end

        def fetch_prices
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gateio-public-api-tickers', expires_in: 30.seconds) do
              ::ExchangeWrapper::Gateio::PublicApi.tickers
            end
          else
            ::ExchangeWrapper::Gateio::PublicApi.tickers
          end
        end

      end
    end
  end
end
