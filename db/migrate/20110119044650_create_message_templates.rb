class CreateMessageTemplates < ActiveRecord::Migration
  def self.up
    create_table :message_templates, :force => true do |t|
      t.string :type, :null => false
      t.string :subject, :null => false
      t.text :body
      t.integer :category_id
      t.integer :author_id
      t.boolean :private, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :message_templates
  end
end
