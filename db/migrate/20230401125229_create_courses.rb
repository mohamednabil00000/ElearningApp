# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.text :path
      t.references :author, index: true, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
