# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_28_124854) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contributors", force: :cascade do |t|
    t.string "role"
    t.bigint "package_id"
    t.bigint "user_id"
    t.index ["package_id"], name: "index_contributors_on_package_id"
    t.index ["user_id"], name: "index_contributors_on_user_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "name"
    t.string "version"
    t.string "title"
    t.text "description"
    t.datetime "publication_date"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
  end

end
