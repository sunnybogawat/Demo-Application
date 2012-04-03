class CreateMessageFolders < ActiveRecord::Migration
  def self.up
    create_table :message_folders, :force => true do |t|
      t.string :type, :null => false
      t.string :name, :null => false
      t.integer :user_id
      t.integer :status, :default => MessageFolder::STATUS[:custom]
      t.timestamps
    end
  end

  def self.down
    drop_table :message_folders
  end
end
