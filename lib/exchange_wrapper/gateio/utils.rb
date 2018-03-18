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

          fetch_trading_pairs.each do |tp_hash|
            symbols << tp_hash['base_asset']
            symbols << tp_hash['quote_asset']
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_trading_pairs.each do |tp_hash|
            trading_pairs << [
              tp_hash['symbol'],
              tp_hash['base_asset'],
              tp_hash['quote_asset']
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
            # confusing... gateio refers to the opposite symbols
            # so quote/base instead of base/quote
            volume << {
              'symbol' => md_hash['symbol'],
              'base_volume' => md_hash['quoteVolume'],
              'quote_volume' => md_hash['baseVolume']
            }
          end

          volume
        end

        private

        def fetch_trading_pairs
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gateio-public-api-pairs', expires_in: 30.seconds) do
              ::ExchangeWrapper::Gateio::PublicApi.pairs
            end
          else
            ::ExchangeWrapper::Gateio::PublicApi.pairs
          end.map do |tp|
            assets = tp.to_s.split('_')
            if tp.present? && assets[0].present? && assets[1].present?
              base_asset = assets[0].to_s.upcase
              quote_asset = assets[1].to_s.upcase
              {
                'symbol' => "#{base_asset}/#{quote_asset}",
                'base_asset' => base_asset,
                'quote_asset' => quote_asset
              }
            else
              nil
            end
          end.compact
        end

        def fetch_metadata
          metadata = []

          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gateio-public-api-tickers', expires_in: 30.seconds) do
              ::ExchangeWrapper::Gateio::PublicApi.tickers
            end
          else
            ::ExchangeWrapper::Gateio::PublicApi.tickers
          end.each do |tp, md_hash|
            assets = tp.to_s.split('_')
            if tp.present? && assets[0].present? && assets[1].present?
              base_asset = assets[0].to_s.upcase
              quote_asset = assets[1].to_s.upcase

              metadata << md_hash.merge('symbol' => "#{base_asset}/#{quote_asset}")
            end
          end

          metadata
        end

      end
    end
  end
end
