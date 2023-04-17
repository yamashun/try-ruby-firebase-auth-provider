class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :client_id
      t.string :client_secret
      t.string :redirect_uris
      t.string :scope

      t.timestamps
    end
  end
end
