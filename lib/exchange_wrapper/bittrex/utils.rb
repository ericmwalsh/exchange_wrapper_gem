# ::ExchangeWrapper::Bittrex::Utils
# https://bittrex.com/home/api
module ExchangeWrapper
  module Bittrex
    class Utils
      class << self

        def holdings(key, secret) # string, string
          raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
          holdings = {}
          ::ExchangeWrapper::Bittrex::AccountApi.get_balances(
            key,
            secret
          )['result'].each do |currency|
            amount = currency['Available'].to_f
            if amount > 0.0 && !currency['Currency'].nil?
              holdings[currency['Currency']] = amount
            end
          end

          holdings
        end

        def symbols
          symbols = []
          currencies = ::ExchangeWrapper::Bittrex::PublicApi.get_currencies['result']

          currencies.each do |currency|
            if currency['IsActive'] && !currency['Currency'].nil?
              symbols << currency['Currency']
            end
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []
          markets = ::ExchangeWrapper::Bittrex::PublicApi.get_markets['result']

          markets.each do |market|
            if market['IsActive'] && !market['MarketCurrency'].nil? && !market['BaseCurrency'].nil?
              trading_pairs << [
                "#{market['MarketCurrency']}/#{market['BaseCurrency']}",
                market['MarketCurrency'],
                market['BaseCurrency']
              ]
            end
          end
          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        def prices
          prices = []
          fetch_metadata.each do |market|
            if market['Last'].present?
              prices << {
                'symbol' => market['symbol'],
                'price' => market['Last']
              }
            end
          end

          prices
        end

        def metadata
          fetch_metadata
        end

        def volume
          volume = []
          fetch_metadata.each do |market|
            if market['BaseVolume'].present? && market['Volume'].present?
              # we have swapped the order of the currencies in the
              # bittrex pairs which is why the volume and base_volume
              # seem to be switched
              volume << {
                'symbol' => market['symbol'],
                'base_volume' => market['Volume'],
                'quote_volume' => market['BaseVolume']
              }
            end
          end

          volume
        end

        private

        def fetch_metadata
          if defined?(::Rails)
            ::Rails.cache.fetch('bittrex-public-api-get-market-summaries', expires_in: 30.seconds) do
              ::ExchangeWrapper::Bittrex::PublicApi.get_market_summaries
            end
          else
            ::ExchangeWrapper::Bittrex::PublicApi.get_market_summaries
          end['result'].map do |md_hash|
            assets = md_hash['MarketName'].to_s.split('-')
            if md_hash['MarketName'].present? && assets[0].present? && assets[1].present?
              md_hash.merge('symbol' => "#{assets[1]}/#{assets[0]}")
            else
              nil
            end
          end.compact
        end

      end
    end
  end
end
