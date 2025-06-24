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

ActiveRecord::Schema[8.0].define(version: 2025_06_24_063650) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "ckb_udts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "graph_channels", force: :cascade do |t|
    t.string "channel_outpoint"
    t.string "node1"
    t.string "node2"
    t.bigint "created_timestamp"
    t.jsonb "update_info_of_node1", default: {}
    t.jsonb "update_info_of_node2", default: {}
    t.bigint "capacity"
    t.string "chain_hash"
    t.jsonb "udt_type_script", default: {}
    t.bigint "ckb_udt_id"
    t.bigint "ckb_open_tx_id"
    t.bigint "ckb_close_tx_id"
    t.bigint "ckb_output_id"
    t.bigint "ckb_address_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_outpoint"], name: "index_graph_channels_on_channel_outpoint", unique: true
  end

  create_table "graph_nodes", force: :cascade do |t|
    t.string "node_name"
    t.string "addresses", default: [], array: true
    t.string "peer_id"
    t.string "node_id"
    t.bigint "timestamp"
    t.string "chain_hash"
    t.bigint "auto_accept_min_ckb_funding_amount"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_graph_nodes_on_deleted_at"
    t.index ["node_id"], name: "index_graph_nodes_on_node_id", unique: true
  end

  create_table "udt_cfg_infos", force: :cascade do |t|
    t.bigint "graph_node_id"
    t.bigint "ckb_udt_id"
    t.string "name"
    t.jsonb "script", default: {}
    t.bigint "auto_accept_amount"
    t.jsonb "cell_deps", default: []
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_udt_cfg_infos_on_deleted_at"
    t.index ["graph_node_id", "script"], name: "index_udt_cfg_infos_on_graph_node_id_and_script", unique: true
    t.index ["graph_node_id"], name: "index_udt_cfg_infos_on_graph_node_id"
  end
end
