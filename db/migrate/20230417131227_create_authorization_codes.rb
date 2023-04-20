class CreateAuthorizationCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :authorization_codes do |t|
      t.string :code
      t.references :request, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at

      t.timestamps
    end
  end
end
