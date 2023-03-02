class CreateBulkDiscount < ActiveRecord::Migration[5.2]
  def change
    create_table :bulk_discounts do |t|
      t.string :name
      t.integer :percentage_discount
      t.integer :threshold
      t.references :merchant, foreign_key: true
    end
  end
end
