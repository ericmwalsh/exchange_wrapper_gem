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
          fetch_market_summaries.each do |market|
            if !market['MarketName'].nil? && !market['Last'].nil?
              formatted_symbol = begin
                currencies = market['MarketName'].split('-')
                "#{currencies[1]}/#{currencies[0]}"
              end

              prices << {
                'symbol' => formatted_symbol,
                'price' => market['Last']
              }
            end
          end

          prices
        end

        def metadata
          metadata = []
          fetch_market_summaries.each do |market|
            if !market['MarketName'].nil?
              formatted_symbol = begin
                currencies = market['MarketName'].split('-')
                "#{currencies[1]}/#{currencies[0]}"
              end

              metadata << market.merge('symbol' => formatted_symbol)
            end
          end

          metadata
        end

        private

        def fetch_market_summaries
          if defined?(::Rails)
            ::Rails.cache.fetch('bittrex-public-api-get-market-summaries', expires_in: 30.seconds) do
              ::ExchangeWrapper::Bittrex::PublicApi.get_market_summaries
            end
          else
            ::ExchangeWrapper::Bittrex::PublicApi.get_market_summaries
          end['result']
        end

      end
    end
  end
end
