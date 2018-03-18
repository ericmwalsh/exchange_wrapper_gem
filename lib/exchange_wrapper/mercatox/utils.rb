# ::ExchangeWrapper::Mercatox::Utils
# https://mercatox.com/
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

          fetch_metadata.each do |md_hash|
            assets = md_hash['symbol'].split('/')

            symbols << assets[0]
            symbols << assets[1]
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

            volume << {
              'symbol' => md_hash['symbol'],
              'base_volume' => md_hash['baseVolume'],
              'quote_volume' => md_hash['quoteVolume']
            }
          end

          volume
        end

        private

        def fetch_metadata
          metadata = []

          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/mercatox-public-api-market', expires_in: 30.seconds) do
              ::ExchangeWrapper::Mercatox::PublicApi.market
            end
          else
            ::ExchangeWrapper::Mercatox::PublicApi.market
          end['pairs'].each do |tp, md_hash|
            next unless tp.present? && md_hash['isFrozen'] == "0"
            assets = tp.to_s.split('_')
            base_asset = assets[0]
            quote_asset = assets[1]
            next unless base_asset.present? && quote_asset.present?

            metadata << md_hash.merge('symbol' => "#{assets[0]}/#{assets[1]}")
          end

          metadata
        end

      end
    end
  end
end
