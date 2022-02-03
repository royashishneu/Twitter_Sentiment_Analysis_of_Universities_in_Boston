ActiveRecord::Schema.define(version: 2021_10_25_214159) do

    create_table "records", force: :cascade do |t|
        t.string "key_name"
        t.string "result"

        t.datetime "created_at", precision: 6, null: false
        t.datetime "updated_at", precision: 6, null: false
    end
  
end