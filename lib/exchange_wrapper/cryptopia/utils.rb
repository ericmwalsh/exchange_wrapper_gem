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
          tps = fetch_trading_pairs.map {|tp| tp['Label']}

          fetch_prices.each do |market_hash|
            next unless market_hash['LastPrice'].present?
            next unless tps.include? market_hash['Label']

            prices << {
              'symbol' => market_hash['Label'],
              'price' => market_hash['LastPrice']
            }
          end

          prices
        end

        def metadata
          metadata = []
          tps = fetch_trading_pairs.map {|tp| tp['Label']}

          fetch_prices.each do |market_hash|
            next unless tps.include? market_hash['Label']

            metadata << market_hash.merge('symbol' => market_hash['Label'])
          end

          metadata
        end

        def volume
          volume = []
          tps = fetch_trading_pairs.map {|tp| tp['Label']}

          fetch_prices.each do |market_hash|
            next unless market_hash['Volume'].present? && market_hash['BaseVolume'].present?
            next unless tps.include? market_hash['Label']

            # confusing... Cryptopia uses the same order for symbols
            # (base_asset/quote_asset) but they call their quote_asset
            # the base_asset
            volume << {
              'symbol' => market_hash['Label'],
              'base_volume' => market_hash['Volume'],
              'quote_volume' => market_hash['BaseVolume']
            }
          end

          volume
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
          end['Data'].select do |tp_hash|
            tp_hash['Status'] == 'OK' && tp_hash['Label'].present? &&
              tp_hash['Symbol'].present? || tp_hash['BaseSymbol'].present?
          end
        end

        def fetch_prices
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/cryptopia-public-api-get-markets', expires_in: 30.seconds) do
              ::ExchangeWrapper::Cryptopia::PublicApi.get_markets
            end
          else
            ::ExchangeWrapper::Cryptopia::PublicApi.get_markets
          end['Data'].select do |p_hash|
            p_hash['Label'].present?
          end
        end

      end
    end
  end
end
