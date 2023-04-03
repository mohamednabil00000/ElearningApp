# frozen_string_literal: true

class CreateTalentCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :talent_courses do |t|
      t.references :talent, index: true, null: false, foreign_key: { to_table: :users }
      t.references :course, index: true, null: false, foreign_key: true
      t.string :status, nulll: false, default: :Not_started_yet
      t.datetime :finished_at

      t.timestamps
    end
  end
end
