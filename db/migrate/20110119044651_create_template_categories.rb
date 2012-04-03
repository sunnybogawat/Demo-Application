class CreateTemplateCategories < ActiveRecord::Migration
  def self.up
    create_table :template_categories, :force => true do |t|
      t.string :name, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :template_categories
  end
end
