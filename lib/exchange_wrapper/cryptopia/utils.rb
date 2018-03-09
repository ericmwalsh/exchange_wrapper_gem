# ::ExchangeWrapper::Cryptopia::Utils
# https://www.cryptopia.co.nz/Forum/Thread/255
module ExchangeWrapper
  module Cryptopia
    class Utils
      class << self

        # def holdings(key, secret) # string, string
        #   raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
        #   holdings = {}
        #   ::ExchangeWrapper::Cryptopia::AccountApi.balances(
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
            next if symbol_hash['Status'] != 'OK'
            next if symbol_hash['Symbol'].nil?
            symbols << symbol_hash['Symbol']
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_trading_pairs.each do |tp_hash|
            next if tp_hash['Status'] != 'OK'
            next if tp_hash['Label'].nil? || tp_hash['Symbol'].nil? || tp_hash['BaseSymbol'].nil?

            trading_pairs << [
              tp_hash['Label'],
              tp_hash['Symbol'],
              tp_hash['BaseSymbol']
            ]
          end

          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        def prices
          prices = []
          tps = fetch_trading_pairs
          valid_tps = tps.map do |tp|
            tp['Status'] == 'OK' ? tp['Label'] : nil
          end.compact

          fetch_prices.each do |market_hash|
            next if market_hash['Label'].nil? || market_hash['LastPrice'].nil?
            next unless valid_tps.include? market_hash['Label']

            prices << {
              'symbol' => market_hash['Label'],
              'price' => market_hash['LastPrice']
            }
          end

          prices
        end

        def metadata
          metadata = []
          tps = fetch_trading_pairs
          valid_tps = tps.map do |tp|
            tp['Status'] == 'OK' ? tp['Label'] : nil
          end.compact

          fetch_prices.each do |market_hash|
            next if market_hash['Label'].nil?
            next unless valid_tps.include? market_hash['Label']

            metadata << market_hash.merge('symbol' => market_hash['Label'])
          end

          metadata
        end

        private

        def fetch_symbols
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/cryptopia-public-api-get-currencies', expires_in: 30.seconds) do
              ::ExchangeWrapper::Cryptopia::PublicApi.get_currencies
            end
          else
            ::ExchangeWrapper::Cryptopia::PublicApi.get_currencies
          end['Data']
        end

        def fetch_trading_pairs
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/cryptopia-public-api-get-trade-pairs', expires_in: 30.seconds) do
              ::ExchangeWrapper::Cryptopia::PublicApi.get_trade_pairs
            end
          else
            ::ExchangeWrapper::Cryptopia::PublicApi.get_trade_pairs
          end['Data']
        end

        def fetch_prices
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/cryptopia-public-api-get-markets', expires_in: 30.seconds) do
              ::ExchangeWrapper::Cryptopia::PublicApi.get_markets
            end
          else
            ::ExchangeWrapper::Cryptopia::PublicApi.get_markets
          end['Data']
        end

      end
    end
  end
end
