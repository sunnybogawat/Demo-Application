class CreateMessages < ActiveRecord::Migration
  def self.up
  create_table :messages, :force => true do |t|
      t.string :subject, :null => false
      t.text :body
      t.integer :sender_id, :null => false
      t.integer :priority, :default => 0
      t.integer :flag
      t.integer :status, :default => Message::DRAFT
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
