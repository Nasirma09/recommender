class CreateMigrationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :recommendation_interactions do |t|
      t.string   :user_key,         null: false
      t.string   :item_id,          null: false
      t.string   :interaction_type, null: false
      t.boolean  :anonymous,        null: false
      t.datetime :occurred_at,      null: false
    end
    add_index :recommendation_interactions, [:user_key, :item_id]

    # The output: for each item, its most similar items
    create_table :item_similarities do |t|
      t.string  :item_id,             null: false
      t.string  :neighbour_item_id,   null: false
      t.float   :score,               null: false
      t.integer :shared_user_count,   null: false
    end
    add_index :item_similarities, [:item_id, :score]  
  end
end
