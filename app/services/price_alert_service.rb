class PriceAlertService < ApplicationService
  attr_reader :coin_name, :current_price

  def initialize(current_price, coin_name='BTC')
    @coin_name = coin_name
    @current_price = current_price
  end

  def call
    trigger_alerts
  end

  private

  def trigger_alerts
    alerts = Alert.includes(:user).where(coin_name: coin_name, status: :created, target_price: current_price)

    alerts.find_each do |alert|
      alert.update(status: :triggered)
      puts "Alert triggered for user #{alert.user.email} at price #{current_price}"
    end
  end

  def trigger_alerts
    alerts = Alert.includes(:user).where(coin_name: coin_name, status: :created, target_price: current_price)

    return if alerts.empty?

    user_ids = alerts.pluck(:user_id).uniq
    alerts.update_all(status: :triggered)

    SendAlertNotificationJob.perform_later(user_ids)
  end
end
