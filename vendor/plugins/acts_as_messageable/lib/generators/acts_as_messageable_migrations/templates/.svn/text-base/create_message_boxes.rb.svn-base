class CreateMessageBoxes < ActiveRecord::Migration
  def self.up
    create_table :message_boxes, :force => true do |t|
      t.integer :messageable_id, :null => false
      t.string :messageable_type, :null => false
      t.integer :messages_per_page, :default => 10
      t.boolean :email_notification, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :message_boxes
  end

end