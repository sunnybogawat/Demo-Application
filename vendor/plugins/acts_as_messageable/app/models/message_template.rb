class MessageTemplate < ActiveRecord::Base
  belongs_to :author, :class_name => 'MessageBox'
  belongs_to :template_category, :foreign_key => 'category_id'
end
