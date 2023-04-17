class CreateAuthorizationCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :authorization_codes do |t|
      t.string :code
      t.datetime :expires_at

      t.timestamps
    end
  end
end
