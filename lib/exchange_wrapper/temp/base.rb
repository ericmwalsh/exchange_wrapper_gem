require 'httparty'
# ::ExchangeWrapper::Temp::Base
module ExchangeWrapper
  module Temp
    class Base

      include ::HTTParty
      # base_uri ENV['EXAMPLE_BASE_URI']

      class << self

        private

        def refresh_request(uri, params = {})
          parsed_response = get(
            uri,
            {
              query: params
            }
          ).parsed_response

          if defined?(::Rails)
            ::Rails.cache.write(
              "#{base_uri}#{uri} #{params.to_json}",
              parsed_response
            ) && parsed_response
          else
            parsed_response
          end
        end

        def request(uri, params = {}, expires_in = 3600) # 1.hour)
          if defined?(::Rails)
            ::Rails.cache.fetch("#{base_uri}#{uri} #{params.to_json}", expires_in: expires_in) do
              get(
                uri,
                {
                  query: params
                }
              ).parsed_response
            end
          else
            get(
              uri,
              {
                query: params
              }
            ).parsed_response
          end
        end

        def delete_key(uri, params = {})
          if defined?(::Rails)
            ::Rails.cache.delete("#{base_uri}#{uri} #{params.to_json}")
          end
        end

      end
    end
  end
end
# trick to allow correct loading
# base class needs to be loaded before these classes bc they inherit from base
require_relative 'coin_market_cap'
require_relative 'crypto_compare'
