Rails.application.config.after_initialize do
  Thread.new do
    StartBinanceWebSocketJob.perform_later
  end
end
