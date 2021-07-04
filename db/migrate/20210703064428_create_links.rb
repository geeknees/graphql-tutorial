class CreateLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :links do |t|
      t.string :url, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
