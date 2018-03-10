require_relative 'account_api'
require_relative 'key_middleware'
require_relative 'public_api'
require_relative 'signature_middleware'
require_relative 'utils'
# ::ExchangeWrapper::Gemini::Base
module ExchangeWrapper
  module Gemini
    class Base
      BASE_URL = 'https://api.gemini.com/v1' # ENV['GEMINI_URI]
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
          # {
          #   "result":"error",
          #   "reason":"Bad Request",
          #   "message":"Supplied value 'btcusdz' is not a valid symbol.  Please correct your API request to use one of the supported symbols: [btcusd, ethbtc, ethusd]"
          # }
          case status
          when 429
            disable_requests
            raise ::Exceptions::GeminiApiRateLimitError.new(body, status)
          when 400, 403, 404
            # user side
            raise ::Exceptions::GeminiApiInputError.new(body, status)
          when 500, 502, 503
            raise ::Exceptions::GeminiApiServerError.new(body, status)
          end
        end

        def disable_requests
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/gemini-requests-disabled', expires_in: 3.minutes) do
              true
            end
          end
        end

        def enable_requests
          if defined?(::Rails)
            ::Rails.cache.delete('ExchangeWrapper/gemini-requests-disabled')
          end
        end

        def requests_disabled?
          if defined?(::Rails)
            ::Rails.cache.read('ExchangeWrapper/gemini-requests-disabled').present?
          else
            false
          end
        end

        def public_client(adapter = DEFAULT_ADAPTER)
          ::Faraday.new(url: "#{BASE_URL}") do |conn|
            conn.request :json
            conn.response :json, content_type: /\bjson$/
            conn.adapter adapter
          end
        end

        def signed_client(api_key, secret_key, adapter = DEFAULT_ADAPTER)
          ::Faraday.new(url: "#{BASE_URL}") do |conn|
            conn.response :json, content_type: /\bjson$/
            conn.use ::ExchangeWrapper::Gemini::KeyMiddleware, api_key
            conn.use ::ExchangeWrapper::Gemini::SignatureMiddleware, secret_key
            conn.adapter adapter
          end
        end

      end
    end
  end
end
