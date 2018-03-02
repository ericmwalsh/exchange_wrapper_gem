# ::ExchangeWrapper::Gdax::Utils
module ExchangeWrapper
  module Gdax
    class Utils
      class << self

        def holdings(key, secret, passphrase)
          holdings = {}
          ::ExchangeWrapper::Gdax::AccountApi.accounts(
            key,
            secret,
            passphrase
          ).each do |currency|
            amount = currency['available'].to_f
            if amount > 0.0
              holdings[currency['currency']] = amount
            end
          end

          holdings
        end

        def symbols(key, secret, passphrase)
          symbols = []

          ::ExchangeWrapper::Gdax::PublicApi.currencies(
            key,
            secret,
            passphrase
          ).each do |currency|
            next unless currency['status'] == 'online'
            symbols << currency['id']
          end

          symbols.sort!.uniq!

          symbols
        end

        def trading_pairs(key, secret, passphrase)
          trading_pairs = []

          fetch_products(key, secret, passphrase).each do |product|
            next unless product['status'] == 'online'

            trading_pairs << [
              product['display_name'],
              product['base_currency'],
              product['quote_currency']
            ]
          end
          # sort by symbol
          trading_pairs.sort! {|tp_0, tp_1| tp_0[0] <=> tp_1[0]}

          trading_pairs
        end

        # prices
        def prices
          prices = []
          if defined?(::Rails) && tps = ::Rails.cache.read('gdax-public-api-products')
            # [ ['BCHBTC', 'BCH', 'BTC'] ]
            products = tps.map {|tp| "#{tp[1]}-#{tp[2]}"}
            ws = ::ExchangeWrapper::Gdax::Websocket.new(
              products: products
            )
          else
            products = ::ExchangeWrapper::Gdax::Websocket::PRODUCTS
            ws = ::ExchangeWrapper::Gdax::Websocket.new
          end

          count = 0
          ws.ticker do |resp|
            prices << {
              'symbol' => resp['product_id'].sub(/-/,'/'),
              'price' => resp['price']
            }
            count+=1
            ws.stop! if count == products.size
          end
          ws.start!

          prices
        end

        private

        def fetch_products(key, secret, passphrase)
          if defined?(::Rails)
            ::Rails.cache.fetch('gdax-public-api-products', expires_in: 29.minutes) do
              ::ExchangeWrapper::Gdax::PublicApi.products(
                key,
                secret,
                passphrase
              )
            end
          else
            ::ExchangeWrapper::Gdax::PublicApi.products(
              key,
              secret,
              passphrase
            )
          end
        end

        def fiat_currencies
          [
            'EUR',
            'GBP',
            'USD'
          ]
        end

      end
    end
  end
end
