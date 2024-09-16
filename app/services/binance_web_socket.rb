require 'faye/websocket'
require 'eventmachine'
require 'json'

class BinanceWebSocket < ApplicationService
  def initialize
    @websocket_url = 'wss://stream.binance.com:9443/ws/btcusdt@trade'
  end

  def call
    EM.run do
      ws = Faye::WebSocket::Client.new(@websocket_url)

      ws.on :open do |event|
        puts 'Connected to Binance WebSocket'
      end

      ws.on :message do |event|
        data = JSON.parse(event.data)
        price = data['p'].to_f
        puts "BTC price update: #{price}"

        trigger_alerts(price)
      end

      ws.on :close do |event|
        puts 'Connection closed'
        EM.stop
      end
    end
  end

  def trigger_alerts(price)
    PriceAlertService.call(price)
  end
end
