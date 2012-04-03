class CreateDefaultTemplates < ActiveRecord::Migration
  def self.up
    create_table :default_templates, :force => true do |t|
      t.column :message, :longtext
      t.string :title, :limit => 80
      t.timestamps
    end
  end
  def self.down
    drop_table :default_templates
  end
end
