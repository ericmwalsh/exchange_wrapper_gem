# ::ExchangeWrapper::Temp::Base
module ExchangeWrapper
  module Temp
    class Base

      include HTTParty
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

        Rails.cache.write(
            "#{base_uri}#{uri} #{params.to_json}",
            parsed_response
          ) && parsed_response
        end

        def request(uri, params = {}, expires_in = 1.hour)
          Rails.cache.fetch("#{base_uri}#{uri} #{params.to_json}", expires_in: expires_in) do
            get(
              uri,
              {
                query: params
              }
            ).parsed_response
          end
        end

        def delete_key(uri, params = {})
          Rails.cache.delete("#{base_uri}#{uri} #{params.to_json}")
        end

      end
    end
  end
end
