class CreateQuickMessages < ActiveRecord::Migration
  def self.up
    create_table :quick_messages, :force => true do |t|
      t.column :message, :longtext
      t.string :title, :limit => 80
      t.timestamps
    end
  end
  def self.down
    drop_table :quick_messages
  end
end