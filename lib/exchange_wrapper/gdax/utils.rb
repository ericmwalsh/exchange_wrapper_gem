# ::ExchangeWrapper::Gdax::Utils
# https://docs.gdax.com/?ruby
module ExchangeWrapper
  module Gdax
    class Utils
      class << self

        def holdings(key, secret, passphrase) # string, string, string
          raise ::Exceptions::InvalidInputError unless key.present? && secret.present? && passphrase.present?
          holdings = {}
          ::ExchangeWrapper::Gdax::AccountApi.accounts(
            key,
            secret,
            passphrase
          ).each do |currency|
            amount = currency['available'].to_f
            if amount > 0.0 && currency['currency'].present?
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
        raise ::Exceptions::InvalidInputError unless key.present? && secret.present? && passphrase.present?
          symbols = []

          ::ExchangeWrapper::Gdax::PublicApi.currencies(
            key,
            secret,
            passphrase
          ).each do |currency|
            next unless currency['status'] == 'online'
            next if currency['id'].nil?
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
        raise ::Exceptions::InvalidInputError unless key.present? && secret.present? && passphrase.present?
          trading_pairs = []

          fetch_products(key, secret, passphrase).each do |product|
            next unless product['status'] == 'online'
            next if product['display_name'].nil? || product['base_currency'].nil? || product['quote_currency'].nil?
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
          key = ENV['GDAX_API_KEY'],
          secret = ENV['GDAX_API_SECRET'],
          passphrase = ENV['GDAX_API_PASSPHRASE']
        ) # string, string, string
          prices = []

          if defined?(::Rails)
            ::Rails.cache.read('ExchangeWrapper/gdax-utils-metadata') || fetch_metadata(key, secret, passphrase)
          else
            fetch_metadata(key, secret, passphrase)
          end.each do |md_hash|
            next unless md_hash['price'].present?
            prices << {
              'symbol' => md_hash['symbol'],
              'price' => md_hash['price']
            }
          end

          prices
        end

        def metadata(
          key = ENV['GDAX_API_KEY'],
          secret = ENV['GDAX_API_SECRET'],
          passphrase = ENV['GDAX_API_PASSPHRASE']
        ) # string, string, string
          if defined?(::Rails)
            ::Rails.cache.read('ExchangeWrapper/gdax-utils-metadata') || fetch_metadata(key, secret, passphrase)
          else
            fetch_metadata(key, secret, passphrase)
          end
        end

        def volume(
          key = ENV['GDAX_API_KEY'],
          secret = ENV['GDAX_API_SECRET'],
          passphrase = ENV['GDAX_API_PASSPHRASE']
        ) # string, string, string
          volume = []
          if defined?(::Rails)
            ::Rails.cache.read('ExchangeWrapper/gdax-utils-metadata') || fetch_metadata(key, secret, passphrase)
          else
            fetch_metadata(key, secret, passphrase)
          end.each do |md_hash|
            next unless md_hash['volume_24h'].present? && md_hash['low_24h'].present?
            # have to use low to guess quote_volume because no vwap present
            # and no quote volume present
            volume  << {
              'symbol' => md_hash['symbol'],
              'base_volume' => md_hash['volume_24h'],
              'quote_volume' => md_hash['price'].to_f * md_hash['volume_24h'].to_f
            }
          end

          volume
        end

        private

        def fetch_metadata(
          key = ENV['GDAX_API_KEY'],
          secret = ENV['GDAX_API_SECRET'],
          passphrase = ENV['GDAX_API_PASSPHRASE']
        ) # string, string, string
          raise ::Exceptions::InvalidInputError unless key.present? && secret.present? && passphrase.present?

          metadata = []
          tps = trading_pairs(key, secret, passphrase)

          if tps.present?
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

            count+=1
            ws.stop! if count == products.size
          end

          ws.error do |resp|
            raise ::Exceptions::ApiServerError, resp.to_json
          end

          ws.start!

          if products & metadata.map {|md| md['product_id']} != products
            raise ::Exceptions::OutdatedError
          end

          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gdax-utils-metadata', expires_in: 30.seconds) do
              metadata
            end
          end

          metadata
        end

        def fetch_products(
          key = ENV['GDAX_API_KEY'],
          secret = ENV['GDAX_API_SECRET'],
          passphrase = ENV['GDAX_API_PASSPHRASE']
        ) # string, string, string
          raise ::Exceptions::InvalidInputError unless key.present? && secret.present? && passphrase.present?
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

      end
    end
  end
end
