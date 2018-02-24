require_relative "../base_middleware"
# ::ExchangeWrapper::Bittrex::SignatureMiddleware
module ExchangeWrapper
  module Bittrex
    class SignatureMiddleware < ::ExchangeWrapper::BaseMiddleware

      def initialize(app, secret_key)
        super(app)
        @secret_key = secret_key
      end

      # Sign the query string using HMAC(sha-512) and appends to header
      def call(env)
        value = OpenSSL::HMAC.hexdigest(
          'sha512',
          @secret_key,
          env.url.to_s
        )

        env.request_headers['apisign'] = value

        @app.call env
      end

    end
  end
end
