class MessageFolder < ActiveRecord::Base
  has_many :conversations, :class_name => 'MessageConversation'

  validates_presence_of :name

  STATUS = {:inbox => 1, :sentbox => 2, :drafts => 3, :custom => 0}

  def validate
    if MessageFolder.exists?(:name => self.name, :user_id => self.user_id)
      self.errors.add_to_base("Folder already exists, please select a different name")
    end
  end

  class << self
    def get_folder_id(name, user=nil)
      raise "Invalid argument value for folder name: Cannot be nil!" if name.nil?
      conditions = {}
      conditions.store(:name, name)
      # Conditions for DefaultFolder should exclude user_id, it doesn't have one
      conditions.store(:user_id,user.id) if !DefaultFolder.names.include?(name) && user
      folder = find(:first, :select => 'id', :conditions => conditions)
      return folder.nil? ? nil : folder.id
    end

    def names
      find(:all, :select => 'name').collect {|folder| folder.name}
    end
  end
end