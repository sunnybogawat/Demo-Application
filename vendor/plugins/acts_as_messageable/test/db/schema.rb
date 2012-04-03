ActiveRecord::Schema.define :version => 1 do
  create_table :message_boxes, :force => true do |t|
    t.integer :messageable_id, :null => false
    t.string :messageable_type, :null => false
    t.integer :messages_per_page, :default => 10
    t.boolean :email_notification, :default => false
    t.timestamps
  end

  create_table :messages, :force => true do |t|
    t.string :subject, :null => false
    t.text :body
    t.integer :sender_id, :null => false
    t.integer :priority, :default => 0
    t.integer :flag
    t.integer :status, :default => 0
    t.timestamps
  end

  create_table :message_recipients, :id => false, :force => true do |t|
    t.integer :message_id, :null => false
    t.integer :recipient_id, :null => false
  end

  create_table :message_conversations, :force => true do |t|
    t.integer :message_id, :null => false
    t.integer :user_id, :null => false
    t.integer :flag
    t.boolean :read, :default => false
    t.boolean :trashed, :default => false
    t.integer :folder_id, :null => false
    t.integer :status
    t.timestamps
  end

  create_table :message_folders, :force => true do |t|
    t.string :type, :null => false
    t.string :name, :null => false
    t.integer :user_id
    t.integer :status
    t.timestamps
  end

  create_table :message_templates, :force => true do |t|
    t.string :type, :null => false
    t.string :subject, :null => false
    t.text :body
    t.integer :category_id
    t.integer :author_id
    t.boolean :private, :null => false
    t.timestamps
  end

  create_table :template_categories, :force => true do |t|
    t.string :name, :null => false
    t.timestamps
  end

  create_table :dummy_users, :force => true do |t|
    t.string :name, :null => false
    t.string :email, :null => false
  end

  create_table :quick_messages, :force => true do |t|
    t.column :message, :longtext
    t.string :title, :limit => 80
    t.timestamps
  end
end