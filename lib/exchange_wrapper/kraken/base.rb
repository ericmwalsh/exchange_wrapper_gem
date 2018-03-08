require 'faraday'
# require 'faraday_middleware'

# require_relative 'account_api'
require_relative 'public_api'
require_relative 'utils'
# ::ExchangeWrapper::Kraken::Base
module ExchangeWrapper
  module Kraken
    class Base
      BASE_URL = 'https://api.kraken.com/0' # ENV['KRAKEN_URI]
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

        # def signed_request(method, url, api_key, secret_key, options = {})
        #   request(
        #     signed_client(api_key, secret_key),
        #     method,
        #     url,
        #     options
        #   )
        # end

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
          when 200
            if body['error'] != []
              raise ::Exceptions::KrakenApiInputError.new(body, status)
            end
          when 429
            disable_requests
            raise ::Exceptions::KrakenApiRateLimitError.new(body, status)
          when 400, 403, 404
            # user side
            raise ::Exceptions::KrakenApiInputError.new(body, status)
          when 500, 502, 503
            raise ::Exceptions::KrakenApiServerError.new(body, status)
          end
        end

        def disable_requests
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/kraken-requests-disabled', expires_in: 3.minutes) do
              true
            end
          end
        end

        def enable_requests
          if defined?(::Rails)
            ::Rails.cache.delete('ExchangeWrapper/kraken-requests-disabled')
          end
        end

        def requests_disabled?
          if defined?(::Rails)
            ::Rails.cache.read('ExchangeWrapper/kraken-requests-disabled').present?
          else
            false
          end
        end

        def public_client(adapter = DEFAULT_ADAPTER)
          ::Faraday.new(url: "#{BASE_URL}") do |conn|
            conn.request :json
            # conn.response :logger
            conn.response :json, content_type: /\bjson$/
            conn.adapter adapter
          end
        end

        # def signed_client(api_key, secret_key, adapter = DEFAULT_ADAPTER)
        #   ::Faraday.new(url: "#{BASE_URL}") do |conn|
        #     conn.response :json, content_type: /\bjson$/
        #     conn.use ::ExchangeWrapper::Kraken::KeyMiddleware, api_key
        #     conn.use ::ExchangeWrapper::Kraken::SignatureMiddleware, secret_key
        #     conn.adapter adapter
        #   end
        # end

      end
    end
  end
end
