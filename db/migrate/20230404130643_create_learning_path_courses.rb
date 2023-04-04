# frozen_string_literal: true

class CreateLearningPathCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :learning_path_courses do |t|
      t.references :learning_path, index: true, null: false, foreign_key: true
      t.references :course, index: true, null: false, foreign_key: true

      t.timestamps
    end
  end
end
