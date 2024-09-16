class AddIndexToAlertsOnCoinNameAndStatusAndTargetPrice < ActiveRecord::Migration[7.0]
  def change
    add_index :alerts, [:coin_name, :status, :target_price], name: 'index_alerts_on_coin_name_and_status_and_target_price'
  end
end
