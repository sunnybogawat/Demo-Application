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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110120101541) do

  create_table "default_templates", :force => true do |t|
    t.text     "message",    :limit => 2147483647
    t.string   "title",      :limit => 80
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_boxes", :force => true do |t|
    t.integer  "messageable_id",                        :null => false
    t.string   "messageable_type",                      :null => false
    t.integer  "messages_per_page",  :default => 10
    t.boolean  "email_notification", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_conversations", :force => true do |t|
    t.integer  "message_id",                    :null => false
    t.integer  "user_id",                       :null => false
    t.integer  "flag"
    t.boolean  "read",       :default => false
    t.boolean  "trashed",    :default => false
    t.integer  "folder_id",                     :null => false
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_folders", :force => true do |t|
    t.string   "type",                      :null => false
    t.string   "name",                      :null => false
    t.integer  "user_id"
    t.integer  "status",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_recipients", :id => false, :force => true do |t|
    t.integer "message_id",   :null => false
    t.integer "recipient_id", :null => false
  end

  create_table "message_templates", :force => true do |t|
    t.string   "type",        :null => false
    t.string   "subject",     :null => false
    t.text     "body"
    t.integer  "category_id"
    t.integer  "author_id"
    t.boolean  "private",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "subject",                   :null => false
    t.text     "body"
    t.integer  "sender_id",                 :null => false
    t.integer  "priority",   :default => 0
    t.integer  "flag"
    t.integer  "status",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quick_messages", :force => true do |t|
    t.text     "message",    :limit => 2147483647
    t.string   "title",      :limit => 80
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "template_categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "hashed_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "lastname"
  end

end
