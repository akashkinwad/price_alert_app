class CreateAlerts < ActiveRecord::Migration[7.0]
  def change
    create_table :alerts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :coin_name
      t.decimal :target_price
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
