# ::ExchangeWrapper::Temp::CoinMarketCap
module ExchangeWrapper
  module Temp
    class CoinMarketCap < ::ExchangeWrapper::Temp::Base
      base_uri 'https://api.coinmarketcap.com/v1' # ENV['COIN_MARKET_CAP_URI']

      class << self

        def currency(params = {})
          request('/ticker', params.merge(limit: 0))
        end

        alias_method :snapshot, :currency
        alias_method :get_request, :currency

        def refresh(params = {})
          parsed_response = refresh_request('/ticker', params.merge(limit: 0))
          symbols = parsed_response.map {|currency| currency['symbol']}
          Rails.cache.write(
            'symbols',
            symbols
          ) && symbols
        end

      end
    end
  end
end
