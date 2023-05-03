class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
      t.string :request_id
      t.text :state
      t.text :nonce
      t.references :client, null: false, foreign_key: true
      t.datetime :expires_at

      t.timestamps
    end
  end
end
