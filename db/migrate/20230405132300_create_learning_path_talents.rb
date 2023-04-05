# frozen_string_literal: true

class CreateLearningPathTalents < ActiveRecord::Migration[6.1]
  def change
    create_table :talent_learning_paths do |t|
      t.references :learning_path, index: true, null: false, foreign_key: true
      t.references :talent, index: true, null: false, foreign_key: { to_table: :users }
      t.references :current_talent_course, index: true, null: false, foreign_key: { to_table: :talent_courses }

      t.timestamps
    end
  end
end
