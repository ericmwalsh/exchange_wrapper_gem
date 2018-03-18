# ::ExchangeWrapper::Bitstamp::Utils
# https://www.bitstamp.net/api/
module ExchangeWrapper
  module Bitstamp
    class Utils
      class << self

        # def holdings(key, secret) # string, string
        #   raise ::Exceptions::InvalidInputError if key.nil? || secret.nil?
        #   holdings = {}
        #   ::ExchangeWrapper::Bitstamp::AccountApi.balances(
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

          fetch_trading_pairs.each do |market|
            market_symbols = market['name'].split('/')
            symbols << market_symbols[0]
            symbols << market_symbols[1]
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs
          trading_pairs = []

          fetch_trading_pairs.each do |market|
            market_symbols = market['name'].split('/')
            trading_pairs << [
              market['name'],
              market_symbols[0],
              market_symbols[1]
            ]
          end

          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        def prices
          prices = []
          tps = fetch_trading_pairs
          tp_symbols = tps.map {|tp| tp['url_symbol']}

          fetch_tickers(tp_symbols).each.with_index do |market, i|
            next unless market.present? && tps[i]['name'].present?
            next unless market['last'].present?
            prices << {
              'symbol' => tps[i]['name'],
              'price' => market['last']
            }
          end

          prices
        end

        def metadata
          metadata = []
          tps = fetch_trading_pairs
          tp_symbols = tps.map {|tp| tp['url_symbol']}

          fetch_tickers(tp_symbols).each.with_index do |market, i|
            next unless market.present? && tps[i]['name'].present?
            metadata << market.merge('symbol' => tps[i]['name'])
          end

          metadata
        end

        def volume
          volume = []
          tps = fetch_trading_pairs
          tp_symbols = tps.map {|tp| tp['url_symbol']}

          fetch_tickers(tp_symbols).each.with_index do |market, i|
            next unless market.present? && tps[i]['name'].present?
            next unless market['vwap'].present? && market['volume'].present?
            volume << {
              'symbol' => tps[i]['name'],
              'base_volume' => market['volume'],
              'quote_volume' => market['vwap'].to_f * market['volume'].to_f
            }
          end

          volume
        end

        private

        def fetch_trading_pairs
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/bitstamp-public-api-trading-pairs', expires_in: 30.seconds) do
              ::ExchangeWrapper::Bitstamp::PublicApi.trading_pairs
            end
          else
            ::ExchangeWrapper::Bitstamp::PublicApi.trading_pairs
          end.select do |tp_hash|
            assets = tp_hash['name'].to_s.split('/')
            tp_hash['name'].present? && assets[0].present? &&
              assets[1].present? && tp_hash['trading'] == 'Enabled'
          end
        end

        def fetch_tickers(symbols) # array of strings
          if defined?(::Rails)
            symbols.map do |symbol|
              if symbol.nil?
                nil
              else
                ::Rails.cache.fetch("ExchangeWrapper/bitstamp-public-api-ticker-#{symbol}", expires_in: 30.seconds) do
                  ::ExchangeWrapper::Bitstamp::PublicApi.ticker(symbol)
                end
              end
            # cannot compact because of `with_index`
            end#.compact
          else
            symbols.map do |symbol|
              if symbol.nil?
                nil
              else
                ::ExchangeWrapper::Bitstamp::PublicApi.ticker(symbol)
              end
            # cannot compact because of `with_index`
            end#.compact
          end
        end

      end
    end
  end
end
