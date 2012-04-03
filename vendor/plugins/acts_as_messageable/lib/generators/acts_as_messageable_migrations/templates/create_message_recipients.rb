class CreateMessageRecipients < ActiveRecord::Migration
  def self.up
    create_table :message_recipients, :id => false, :force => true do |t|
      t.integer :message_id, :null => false
      t.integer :recipient_id, :null => false
    end
  end

  def self.down
    drop_table :message_recipients
  end
end
