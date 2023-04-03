# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_230_403_120_423) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'courses', force: :cascade do |t|
    t.string 'name', null: false
    t.text 'path'
    t.bigint 'author_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['author_id'], name: 'index_courses_on_author_id'
  end

  create_table 'talent_courses', force: :cascade do |t|
    t.bigint 'talent_id', null: false
    t.bigint 'course_id', null: false
    t.string 'status', default: 'Not_started_yet'
    t.datetime 'finished_at'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['course_id'], name: 'index_talent_courses_on_course_id'
    t.index ['talent_id'], name: 'index_talent_courses_on_talent_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'username'
    t.string 'email'
    t.string 'password_digest'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  add_foreign_key 'courses', 'users', column: 'author_id'
  add_foreign_key 'talent_courses', 'courses'
  add_foreign_key 'talent_courses', 'users', column: 'talent_id'
end
