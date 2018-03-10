# require_relative 'account_api'
require_relative 'public_api'
require_relative 'utils'
# ::ExchangeWrapper::Gateio::Base
module ExchangeWrapper
  module Gateio
    class Base
      BASE_URL = 'https://gate.io/api2' # ENV['GATEIO_URI]
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
            if body.is_a?(Hash) && body['code'].present? && (1..21).include?(body['code'])
              case body['code']
              when 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 14, 16, 17, 18, 19, 20, 21
                raise ::Exceptions::GateioApiInputError.new(body, 400)
              when 4, 15
                disable_requests
                raise ::Exceptions::GateioApiRateLimitError.new(body, 429)
              when 13
                raise ::Exceptions::GateioApiServerError.new(body, 500)
              end
            end
          when 429
            disable_requests
            raise ::Exceptions::ApiRateLimitError.new(body, status)
            # raise ::Exceptions::GateioApiRateLimitError.new(body, status)
          when 400, 403, 404
            # user side
            raise ::Exceptions::ApiInputError.new(body, status)
            # raise ::Exceptions::GateioApiInputError.new(body, status)
          when 500, 502, 503
            raise ::Exceptions::ApiServerError.new(body, status)
          end
        end

        def disable_requests
          if defined?(::Rails)
            ::Rails.cache.fetch('ExchangeWrapper/Gateio-requests-disabled', expires_in: 3.minutes) do
              true
            end
          end
        end

        def enable_requests
          if defined?(::Rails)
            ::Rails.cache.delete('ExchangeWrapper/Gateio-requests-disabled')
          end
        end

        def requests_disabled?
          if defined?(::Rails)
            ::Rails.cache.read('ExchangeWrapper/Gateio-requests-disabled').present?
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
        #     conn.use ::ExchangeWrapper::Gateio::KeyMiddleware, api_key
        #     conn.use ::ExchangeWrapper::Gateio::SignatureMiddleware, secret_key
        #     conn.adapter adapter
        #   end
        # end

      end
    end
  end
end
