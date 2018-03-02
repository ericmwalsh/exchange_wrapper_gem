require 'faraday'
require 'faraday_middleware'

require_relative 'account_api'
require_relative 'public_api'
require_relative 'signature_middleware'
require_relative 'timestamp_middleware'
require_relative 'utils'
require_relative 'withdraw_api'
# ::ExchangeWrapper::Binance::Base
# https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md
module ExchangeWrapper
  module Binance
    class Base
      BASE_URL = 'https://api.binance.com' # ENV['BINANCE_URI']
      DEFAULT_ADAPTER = ::Faraday.default_adapter

      class << self

        def public_request(method, url, options = {})
          request(
            public_client,
            method,
            url,
            options
          )
        end

        def signed_request(method, url, api_key, secret_key, options = {})
          request(
            signed_client(api_key, secret_key),
            method,
            url,
            options
          )
        end

        def verified_request(method, url, api_key, options = {})
          request(
            verified_client(api_key),
            method,
            url,
            options
          )
        end

        def withdraw_request(method, url, api_key, secret_key, options = {})
          request(
            withdraw_client(api_key, secret_key),
            method,
            url,
            options
          )
        end

        private

        def request(client, method, url, options = {})
          if requests_disabled?
            raise ::Exceptions::ApiRateLimitError
          else
            response = client.send(method) do |req|
              req.url url
              req.params.merge! options
            end
            intercept_errors(response.status, response.body)
            response.body
          end
        end

        def intercept_errors(status, body) # integer, hash
          case status
          when 418, 429
            disable_requests
            raise ::Exceptions::BinanceApiRateLimitError.new(body, status)
          when 401
            # user side
            raise ::Exceptions::BinanceApiInputError.new(body, status)
          when 400...500
            raise ::Exceptions::BinanceApiServerError.new(body, status)
          when 504
            # message sent, status UNKNOWN
            raise ::Exceptions::BinanceApiUnknownError.new(body, status)
          when 500...600
            # binance error
            raise ::Exceptions::BinanceApiServerError.new(body, status)
          end
        end

        def disable_requests
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/binance-requests-disabled', expires_in: 3.minutes) do
              true
            end
          end
        end

        def enable_requests
          if defined?(::Rails)
            ::Rails.cache.delete('ExchangeWrapper/binance-requests-disabled')
          end
        end

        def requests_disabled?
          if defined?(::Rails)
            ::Rails.cache.read('ExchangeWrapper/binance-requests-disabled').present?
          else
            false
          end
        end

        def public_client(adapter = DEFAULT_ADAPTER)
          ::Faraday.new(url: "#{BASE_URL}/api") do |conn|
            conn.request :json
            conn.response :json, content_type: /\bjson$/
            conn.adapter adapter
          end
        end

        def signed_client(api_key, secret_key, adapter = DEFAULT_ADAPTER)
          ::Faraday.new(url: "#{BASE_URL}/api") do |conn|
            conn.request :json
            conn.response :json, content_type: /\bjson$/
            conn.headers['X-MBX-APIKEY'] = api_key
            conn.use ::ExchangeWrapper::Binance::TimestampMiddleware
            conn.use ::ExchangeWrapper::Binance::SignatureMiddleware, secret_key
            conn.adapter adapter
          end
        end

        def verified_client(api_key, adapter = DEFAULT_ADAPTER)
          ::Faraday.new(url: "#{BASE_URL}/api") do |conn|
            conn.response :json, content_type: /\bjson$/
            conn.headers['X-MBX-APIKEY'] = api_key
            conn.adapter adapter
          end
        end

        def withdraw_client(api_key, secret_key, adapter = DEFAULT_ADAPTER)
          ::Faraday.new(url: "#{BASE_URL}/wapi") do |conn|
            conn.request :url_encoded
            conn.response :json, content_type: /\bjson$/
            conn.headers['X-MBX-APIKEY'] = api_key
            conn.use ::ExchangeWrapper::Binance::TimestampMiddleware
            conn.use ::ExchangeWrapper::Binance::SignatureMiddleware, secret_key
            conn.adapter adapter
          end
        end

      end
    end
  end
end
