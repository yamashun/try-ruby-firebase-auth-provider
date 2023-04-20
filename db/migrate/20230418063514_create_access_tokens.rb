class CreateAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :access_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token
      t.string :client_id
      t.string :scope
      t.datetime :expires_at

      t.timestamps
    end
  end
end
