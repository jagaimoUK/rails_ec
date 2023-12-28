class ChangeTable < ActiveRecord::Migration[7.0]
  def change
    change_table :products do |t|
      t.remove :title, :body
      t.text :body
      t.string :name, :image, :price, :action
    end
  end
end
