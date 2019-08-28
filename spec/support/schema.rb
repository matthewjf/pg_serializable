require "active_record/relation"
require "active_record/schema"

ActiveRecord::Base.connection.execute <<-SQL
  DROP TYPE category_type CASCADE;
  CREATE TYPE category_type AS ENUM ('annotation', 'facade');
SQL

ActiveRecord::Schema.define do
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.column "category_type", "category_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_products", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categories_products_on_category_id"
    t.index ["product_id"], name: "index_categories_products_on_product_id"
  end

  create_table "colors", force: :cascade do |t|
    t.string "hex"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "labels", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "label_id"
    t.integer "product_type"
    t.boolean "active", default: true
    t.index ["label_id"], name: "index_products_on_label_id"
  end

  create_table "variations", force: :cascade do |t|
    t.string "name"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "color_id"
    t.index ["color_id"], name: "index_variations_on_color_id"
    t.index ["product_id"], name: "index_variations_on_product_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "type"
    t.string "name"
  end

  add_foreign_key "categories_products", "categories"
  add_foreign_key "categories_products", "products"
  add_foreign_key "products", "labels"
  add_foreign_key "variations", "colors"
  add_foreign_key "variations", "products"
end
