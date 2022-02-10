class CreateDummyUser < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
    end
  end
end