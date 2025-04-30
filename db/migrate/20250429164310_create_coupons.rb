class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code, null: false, index: { unique: true }
      t.integer :status, default: 0
      t.integer :discount_type, null: false
      t.float :discount_value, null: false
      t.references :merchant, null: false, foreign_key: true
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
