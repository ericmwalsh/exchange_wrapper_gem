require_relative "../base_middleware"
# ::ExchangeWrapper::Gemini::SignatureMiddleware
module ExchangeWrapper
  module Gemini
    class SignatureMiddleware < ::ExchangeWrapper::BaseMiddleware

      def initialize(app, secret_key)
        super(app)
        @secret_key = secret_key
      end

      # first append base64-encoded JSON payload to headers
      # then append HMAC_SHA384 signature payload to headers
      def call(env)
        payload = build_payload(env.url, env.body)
        signature = build_signature(payload)

        env.request_headers['X-GEMINI-PAYLOAD'] = payload
        env.request_headers['X-GEMINI-SIGNATURE'] = signature

        @app.call env
      end

      private

      def build_payload(url, body) # string, hash
        payload = {}
        payload['nonce'] = Time.now.to_i
        payload['request'] = stripped_url(url)
        payload.merge!(body) unless body.nil?
        ::Base64.strict_encode64(payload.to_json)
      end

      def stripped_url(url) # string
        url.to_s.sub(::ExchangeWrapper::Gemini::Base::BASE_URL[0...-3], '')
      end

      def build_signature(payload)
        OpenSSL::HMAC.hexdigest(
          'sha384',
          @secret_key,
          payload
        )
      end

    end
  end
end
