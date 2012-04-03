require 'plugin_constants'
class MessageConversation < ActiveRecord::Base
  belongs_to :user, :class_name => 'MessageBox'
  belongs_to :folder, :class_name => 'MessageFolder'
  belongs_to :message

  validates_presence_of :message, :folder, :user
  after_destroy :delete_message


  def self.priorities
    return PluginConstants::PRIORITIES
  end

  def self.flags
    return PluginConstants::FLAGS
  end

  include ModelUtilities

  class << self
    def search(params = {})
      find(:all, :conditions => params)
    end

    def records_exist?(records_array)
      invalid_conversation_ids(records_array) unless records_array.is_a?(Array)
      for record in records_array
        return false unless self.exists?(record)
      end
      true
    end

    def belong_to_same_user?(conversation_ids)
      invalid_conversation_ids(conversation_ids) unless conversation_ids.is_a?(Array)
      user_ids = []
      user_ids = conversation_ids.collect {|id| self.find(id).user_id}.uniq
      user_ids.length.equal?(1)
    end

    def get_user_having_conversations(conversation_ids)
      invalid_conversation_ids(conversation_ids) unless conversation_ids.is_a?(Array)
      belong_to_same_user?(conversation_ids) ? self.find(conversation_ids.first).user : nil
    end

    def trash_selected(conversation_ids, options ={})
      self.process_conversations(conversation_ids, 'trash', options)
    end


    def restore_selected(conversation_ids, options={})
      process_conversations(conversation_ids, 'restore', options)
    end

    def mark_selected_as_read(conversation_ids)
      process_conversations(conversation_ids, 'mark_as_read')
    end

    def move_selected_to_folder(conversation_ids, folder_name)
      raise "Invalid Folder !!" unless MessageFolder.exists?(:name => folder_name)
      options = {}
      options[:folder_name] = folder_name
      process_conversations(conversation_ids, 'move_to(folder_name)', options)
    end

    def process_conversations(conversation_ids, action, options={})
      invalid_conversation_ids(conversation_ids) unless conversation_ids.is_a?(Array)
      invalid_ids = []
      invalid_action_ids = []
      folder_name = options[:folder_name] if options.has_key?(:folder_name)
      conditions = extract_attributes(options)
      for id in conversation_ids
        conversation = conditions.empty? ? self.find(id) : self.find(id, :conditions => conditions) rescue nil
        if conversation
          invalid_action_ids << id unless eval("conversation.#{action}")
        else
          invalid_ids << id
        end
      end
      return invalid_ids, invalid_action_ids
    end

    def mark_selected_as_unread(conversation_ids)
      invalid_conversation_ids(conversation_ids) unless conversation_ids.is_a?(Array)
      invalid_ids = []

      for id in conversation_ids
        conversation = self.find(id) rescue nil
        if conversation
          conversation.mark_as_unread if conversation.read?
        else
          invalid_ids << id
        end
      end
      
      invalid_ids
    end

    def set_selected_with_flag(conversation_ids, flag)
      set_clear_selected_flag(conversation_ids, 'set_flag(flag)', flag)
    end

    def clear_flag_from_selected(conversation_ids)
      set_clear_selected_flag(conversation_ids, 'clear_flag')
    end
    
    def set_clear_selected_flag(conversation_ids, action, flag =nil)
      invalid_conversation_ids(conversation_ids) unless conversation_ids.is_a?(Array)
      invalid_ids = []
      invalid_action_ids = []

      for id in conversation_ids
        conversation = self.find(id) rescue nil
        if conversation
          conversation.trashed? ? invalid_action_ids << id : eval("conversation.#{action}")
        else
          invalid_ids << id
        end
      end

      return invalid_ids, invalid_action_ids
    end
  end

  def save_draft(options = {})
    self.message.save_draft(options)
  end

  def move_to(folder_name)
    return false if is_draft_conversation? || is_sentbox_conversation?
    return self.trash if PluginConstants::TRASH == folder_name

    folder = DefaultFolder.find(:first, :conditions => {:name => folder_name})

    if folder.nil?
      folder = CustomFolder.find(:first, :conditions => {:name => folder_name, :user_id => self.user_id})
    end

    self.folder = folder
    self.trashed = false
    self.save
  end

  def trash
    return false if self.trashed?
    self.trashed = true
    self.save
  end

  def restore
    return false unless self.trashed?
    self.trashed = false
    self.save
  end

  def mark_as_read
    self.read = true
    self.save
  end

  def mark_as_unread
    self.read = false
    self.save
  end

  def set_flag(flag)
    unless flag.nil?
      self.flag = flag
      self.save
    end
  end

  def clear_flag
    self.flag = nil
    self.save
  end

  def reply
    message = self.message.reply
    message.sender = self.user
    message
  end

  def forward
    message = self.message.forward
    message.sender = self.user
    message
  end

  def reply_to_all
    message = self.message.reply_to_all
    message.sender = self.user
    message.recipients.delete(self.user)
    message
  end

  def read?
    self.read
  end

  def unread?
    !self.read
  end

  def trashed?
    self.trashed
  end

  def flagged?(flag=nil)
    flag.nil? ? !self.flag.nil? : flag == self.flag
  end

  def is_draft_conversation?
    self.message.saved_as_draft?
  end

  def is_sentbox_conversation?
    self.message.sent? && self.folder == DefaultFolder.sentbox
  end

  def delete_message
    self.message.delete if is_draft_conversation?
  end

 
  private

  def self.invalid_action
    raise "Invalid Action!!"
  end

  def self.invalid_conversation_ids(conversation_ids)
    raise "Invalid argument value for conversation_ids: #{conversation_ids}. Expects an array"
  end
end