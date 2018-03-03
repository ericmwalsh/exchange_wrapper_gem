# ::ExchangeWrapper::Gdax::Utils
# https://docs.gdax.com/?ruby
module ExchangeWrapper
  module Gdax
    class Utils
      class << self

        def holdings(key, secret, passphrase) # string, string, string
          raise ::Exceptions::InvalidInputError if key.nil? || secret.nil? || passphrase.nil?
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

        def symbols(
          key = ENV['GDAX_API_KEY'],
          secret = ENV['GDAX_API_SECRET'],
          passphrase = ENV['GDAX_API_PASSPHRASE']
        ) # string, string, string
          raise ::Exceptions::InvalidInputError if key.nil? || secret.nil? || passphrase.nil?
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

        def trading_pairs(
          key = ENV['GDAX_API_KEY'],
          secret = ENV['GDAX_API_SECRET'],
          passphrase = ENV['GDAX_API_PASSPHRASE']
        ) # string, string, string
          raise ::Exceptions::InvalidInputError if key.nil? || secret.nil? || passphrase.nil?
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

        def prices(
          yield_md = false,
          key = ENV['GDAX_API_KEY'],
          secret = ENV['GDAX_API_SECRET'],
          passphrase = ENV['GDAX_API_PASSPHRASE']
        ) # boolean, string, string, string
          prices = []
          metadata = []
          tps = if key.nil? || secret.nil? || passphrase.nil?
            []
          else
            trading_pairs(key, secret, passphrase)
          end

          if defined?(::Rails) && tps
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
            hyphenated_symbol = resp['product_id'].sub(/-/,'/')

            metadata << resp.merge(
              'symbol' => hyphenated_symbol
            )
            prices << {
              'symbol' => hyphenated_symbol,
              'price' => resp['price']
            }

            count+=1
            ws.stop! if count == products.size
          end
          ws.start!

          if products & metadata.map {|md| md['product_id']} != products
            raise ::Exceptions::OutdatedError
          end

          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gdax-utils-metadata', expires_in: 58.seconds) do
              metadata
            end
          end

          if yield_md
            metadata
          else
            prices
          end
        end

        def metadata(
          key = ENV['GDAX_API_KEY'],
          secret = ENV['GDAX_API_SECRET'],
          passphrase = ENV['GDAX_API_PASSPHRASE']
        ) # string, string, string
          if defined?(::Rails)
            ::Rails.cache.read('ExchangeWrapper/gdax-utils-metadata') || prices(true)
          else
            prices(true, key, secret, passphrase)
          end
        end

        private

        def fetch_products(key, secret, passphrase) # string, string, string
          raise ::Exceptions::InvalidInputError if key.nil? || secret.nil? || passphrase.nil?
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gdax-public-api-products', expires_in: 29.minutes) do
              ::ExchangeWrapper::Gdax::PublicApi.products(
                key,
                secret,
                passphrase
              ).map {|product| product.as_json}
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
