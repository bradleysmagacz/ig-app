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

ActiveRecord::Schema.define(version: 20170409173130) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hashtags", force: :cascade do |t|
    t.boolean "auto_follow_on",    default: false, null: false
    t.boolean "auto_like_on",      default: false, null: false
    t.string  "name",                              null: false
    t.boolean "auto_comment_on",   default: false, null: false
    t.string  "hashtaggable_type",                 null: false
    t.integer "hashtaggable_id",                   null: false
    t.index ["hashtaggable_type", "hashtaggable_id"], name: "index_hashtags_on_hashtaggable_type_and_hashtaggable_id", using: :btree
    t.index ["name"], name: "index_hashtags_on_name", using: :btree
  end

  create_table "instagram_identities", force: :cascade do |t|
    t.integer  "user_id",                      null: false
    t.string   "website"
    t.string   "api_id"
    t.string   "full_name"
    t.string   "token"
    t.text     "bio"
    t.string   "username"
    t.string   "profile_picture_file_name"
    t.string   "profile_picture_content_type"
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.index ["api_id"], name: "index_instagram_identities_on_api_id", using: :btree
    t.index ["token"], name: "index_instagram_identities_on_token", using: :btree
    t.index ["user_id"], name: "index_instagram_identities_on_user_id", using: :btree
    t.index ["username"], name: "index_instagram_identities_on_username", using: :btree
  end

  create_table "likes", force: :cascade do |t|
    t.integer "sender_id", null: false
    t.string  "media_id",  null: false
    t.index ["sender_id"], name: "index_likes_on_sender_id", using: :btree
  end

  create_table "rate_limits", force: :cascade do |t|
    t.string   "slug",                           null: false
    t.integer  "hourly_limit",                   null: false
    t.datetime "backoff_until"
    t.integer  "backoff_offset",    default: 60, null: false
    t.string   "identifiable_type",              null: false
    t.integer  "identifiable_id",                null: false
    t.index ["identifiable_type", "identifiable_id"], name: "index_rate_limits_on_identifiable_type_and_identifiable_id", using: :btree
    t.index ["slug"], name: "index_rate_limits_on_slug", using: :btree
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "user_id",         null: false
    t.string  "api_user_id",     null: false
    t.string  "outgoing_status"
    t.string  "incoming_status"
    t.index ["user_id"], name: "index_relationships_on_user_id", using: :btree
  end

  create_table "requests", force: :cascade do |t|
    t.datetime "expires_at",    null: false
    t.integer  "rate_limit_id", null: false
    t.index ["rate_limit_id"], name: "index_requests_on_rate_limit_id", using: :btree
  end

  create_table "stats", force: :cascade do |t|
    t.string   "stattable_type"
    t.integer  "stattable_id"
    t.bigint   "num_likes_received",    default: 0, null: false
    t.bigint   "num_likes_sent",        default: 0, null: false
    t.bigint   "num_follows",           default: 0, null: false
    t.bigint   "num_followed_by",       default: 0, null: false
    t.bigint   "num_comments_received", default: 0, null: false
    t.bigint   "num_comments_sent",     default: 0, null: false
    t.bigint   "num_media",             default: 0, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["stattable_type", "stattable_id"], name: "index_stats_on_stattable_type_and_stattable_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "encrypted_password",                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "full_name"
    t.string   "authentication_token",   limit: 30
    t.string   "username"
    t.string   "email"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
