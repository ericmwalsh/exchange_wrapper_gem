# ::ExchangeWrapper::Gdax::Websocket
module ExchangeWrapper
  module Gdax
    class Websocket
      PRODUCTS = [
        'BCH-BTC', 'BCH-EUR', 'BCH-USD', 'BTC-EUR', 'BTC-GBP', 'BTC-USD',
        'ETH-BTC', 'ETH-EUR', 'ETH-USD', 'LTC-BTC', 'LTC-EUR', 'LTC-USD'
      ]

      def initialize(options = {})
        @ws_url = options[:ws_url] || "wss://ws-feed.gdax.com"
        @products = options[:product_ids] || PRODUCTS
        @keepalive = options[:keepalive] || true
        @channels = options[:channels] || ['ticker']

        unless @channels.include? 'heartbeat'
          @channels.push 'heartbeat'
        end

        @message_cb = ->(_data) { nil }
        @received_cb = ->(_data) { nil }
        @open_cb = ->(_data) { nil }
        @match_cb = ->(_data) { nil }
        @ticker_cb = ->(_data) { nil }
        @change_cb = ->(_data) { nil }
        @done_cb = ->(_data) { nil }
        @error_cb = ->(_data) { nil }
      end

      def start!
        if ::EventMachine.reactor_running?
          @reactor_owner = false
          refresh!
        else
          @reactor_owner = true
          ::EM.run { refresh! }
        end
      end

      def stop!
        if @reactor_owner == true
          @socket.onclose = ->(_event) { EM.stop }
        else
          @socket.onclose = ->(_event) { nil }
        end
        @socket.close
      end

      def refresh!
        @socket = ::Faye::WebSocket::Client.new(@ws_url)
        @socket.onopen = method(:ws_opened)
        @socket.onmessage = method(:ws_received)
        @socket.onclose = method(:ws_closed)
        @socket.onerror = method(:ws_error)
      end

      def subscribe!(type = 'subscribe', options = {})
        channels = options[:channels] || @channels
        products = options[:product_ids] || @products
        @socket.send(
          {
            type: type,
            channels: channels,
            product_ids: products
          }.to_json
        )
      end

      def unsubscribe!(options = {})
        subscribe!('unsubscribe', options)
      end

      def ping(options = {})
        msg = options[:payload] || ::Time.now.to_s
        @socket.ping(msg) do |resp|
          yield(resp) if block_given?
        end
      end

      # Run this before processing every message
      def message(&block)
        @message_cb = block
      end

      def received(&block)
        @received_cb = block
      end

      def open(&block)
        @open_cb = block
      end

      def match(&block)
        @match_cb = block
      end

      def ticker(&block)
        @ticker_cb = block
      end

      def change(&block)
        @change_cb = block
      end

      def done(&block)
        @done_cb = block
      end

      def error(&block)
        @error_cb = block
      end

      private

      def ws_opened(_event)
        subscribe!
      end

      def ws_received(event)
        data = ::Coinbase::Exchange::APIObject.new(::JSON.parse(event.data))
        @message_cb.call(data)
        case data['type']
        when 'received' then @received_cb.call(data)
        when 'open' then @open_cb.call(data)
        when 'match' then @match_cb.call(data)
        when 'ticker' then @ticker_cb.call(data)
        when 'change' then @change_cb.call(data)
        when 'done' then @done_cb.call(data)
        when 'error' then @error_cb.call(data)
        end
      end

      def ws_closed(_event)
        if @keepalive
          refresh!
        else
          ::EM.stop
        end
      end

      def ws_error(event)
        fail ::Coinbase::Exchange::WebsocketError, event.data
      end
    end
  end
end
