class CreateMessageConversations < ActiveRecord::Migration
  def self.up
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
  end

  def self.down
    drop_table :message_conversations
  end
end