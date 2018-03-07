require_relative "../base_middleware"
# ::ExchangeWrapper::Gemini::KeyMiddleware
module ExchangeWrapper
  module Gemini
    class KeyMiddleware < ::ExchangeWrapper::BaseMiddleware

      def initialize(app, api_key)
        super(app)
        @api_key = api_key
      end

      # Append api key, content-length, and content-type to headers
      def call(env)
        env.request_headers['Content-Length'] = '0'
        env.request_headers['Content-Type'] = 'text/plain'
        env.request_headers['X-GEMINI-APIKEY'] = @api_key

        @app.call env
      end

    end
  end
end
