class AlertsController < ApplicationController
  before_action :authenticate_request

  def index
    status = params[:status].presence || 'all'
    page = params[:page].presence || 1

    puts "Fetching alerts for user #{@current_user.id} with status #{status} and page #{page}"

    cache_key = "alerts/user-#{@current_user.id}/#{status}/#{page}"

    response_body = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      alerts = fetch_alerts_from_db(status, page)

      {
        alerts: alerts.as_json,
        meta: pagination_meta(alerts)
      }
    end

    render json: response_body
  end

  def create
    alert = @current_user.alerts.new(alert_params)
    if alert.save
      render json: { alert: alert }, status: :created
    else
      render json: { errors: alert.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    alert = @current_user.alerts.find(params[:id])
    if alert.update(status: :deleted)
      render json: { message: 'Alert deleted successfully' }, status: :ok
    else
      render json: { errors: 'Could not delete alert' }, status: :unprocessable_entity
    end
  end

  private

  def fetch_alerts_from_db(status, page)
    alerts = @current_user.alerts
    alerts = alerts.where(status: status) unless status == 'all'
    alerts.page(page).per(10)
  end

  def alert_params
    params.require(:alert).permit(:coin_name, :target_price)
  end
end
