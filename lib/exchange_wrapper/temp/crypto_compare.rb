# ::ExchangeWrapper::Temp::CryptoCompare
module ExchangeWrapper
  module Temp
    class CryptoCompare < ::ExchangeWrapper::Temp::Base
      base_uri 'https://min-api.cryptocompare.com/data' # ENV['CRYPTO_COMPARE_URI']

      class << self

        def snapshots(symbol, params = {})
          response = request(
            '/histoday',
            params.merge(
              fsym: symbol,
              tsym: 'USD'
            ),
            1.minutes
          )
          if response['Response'] == 'Success'
            response['Data']
          else
            # select distinct symbol from currencies except select distinct symbol from cc_snapshots;
            puts "SYMBOL FAILED: #{symbol}"
          end
        end

      end
    end
  end
end
