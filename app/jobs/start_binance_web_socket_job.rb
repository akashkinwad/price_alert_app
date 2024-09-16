class StartBinanceWebSocketJob < ApplicationJob
  queue_as :default

  def perform(*args)
    BinanceWebSocket.call
  end
end
