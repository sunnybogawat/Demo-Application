require 'plugin_constants'
class MessageBox < ActiveRecord::Base
  has_many :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id',
    :conditions => {:status => Message::SENT}
  has_many :draft_messages, :class_name => 'Message', :foreign_key => 'sender_id',
    :conditions => {:status => Message::DRAFT}
  has_many :conversations, :class_name => 'MessageConversation', :foreign_key => 'user_id', :dependent => :destroy
  has_many :folders, :class_name => 'CustomFolder', :foreign_key => 'user_id'
  has_and_belongs_to_many :received_messages, :class_name => 'Message', :join_table => 'message_recipients',
    :foreign_key => 'recipient_id', :association_foreign_key => 'message_id'
  has_many :templates, :class_name => 'CustomTemplate', :foreign_key => 'author_id'
  belongs_to :messageable, :polymorphic => true

  

  class << self
    def find_by_messageable_ids(ids, type)
      self.find(:all, :conditions => ["messageable_id in (?) and messageable_type = ?", ids, type])
    end

    def find_by_messageable_type(type)
      self.find(:all, :conditions => ["messageable_type = ?", type])
    end
  end

  def compose_message(attrs = {})
    Message.sanitize_attributes!(attrs)
    attrs.merge!(:sender_id => self.id)
    Message.new(attrs)
  end

  def compose_message_reply(message)
    send_message(message,'reply')
  end

  def compose_message_forward(message)
    send_message(message,'forward')
  end

  def compose_message_reply_to_all(message)
    send_message(message,'reply_to_all')
  end

  def compose_message_for_action(action, message)
    return case action
    when Message::REPLY then compose_message_reply(message)
    when Message::REPLY_ALL then compose_message_reply_to_all(message)
    when Message::FORWARD then compose_message_forward(message)
    when Message::EDIT then message
    else nil
    end
  end

  def post_message(message)
    invalid_message(message) unless message.is_a?(Message)
    message.sender = self
    message.post
  end

  def find_conversations(options = {})
    conditions, options = construct_conditions(options)
    if conditions.is_a?(Hash)
      conditions.store(:user_id, self.id) 
    else 
      conditions[0] += " AND user_id = ?"
      conditions << self.id
    end
    MessageConversation.all(:conditions => conditions,
      :order => options[:order], :include => [{:message => :sender}])
  end

  def conversations_in_folder(folder_name, options = {})
    if PluginConstants::TRASH == folder_name
      options.merge!(:trashed => true)
      conversations = find_conversations(options)
    else
      folder_id = MessageFolder.get_folder_id(folder_name, self)
      raise "Folder not found!" if folder_id.nil?

      options.store(:folder_id, folder_id)
      options.store(:trashed, false) unless options.has_key?(:trashed)

      # Sorting is implemented by eager loading message and message_box details of the conversation.
      # However when sorting by the sender's name/email 'order by' clause will fail as
      # the sender's name is not stored in the message_boxes table, it is rather fetched
      # dynamically. To overcome this, when sorting by name or email 'order by' clause is bypassed.
      # The resulting row set ordered by default criteria (created_at) is then sorted

      if options[:sort].is_a?(Hash) && !options[:sort][:by].nil?
        if sort_by_sender?(options[:sort][:by])
          conversations = find_conversations(options)
          conversations = conversations.sort_by { |conv| conv.message.sender.name }
          if options[:sort][:order] == PluginConstants::SORT[:order][:desc]
            conversations.reverse!
          end
        else
          merge_sorting_options!(options)
          conversations = find_conversations(options)
        end
      else
        conversations = find_conversations(options)
      end
    end
    conversations
  end

  def merge_sorting_options!(options)
    sort = options.delete(:sort)
    order = "#{sort[:by]} #{sort[:order]}"
    options.store(:order, order)
  end

  def find_conversations_count(options = {})
    self.conversations.count(:conditions => options)
  end

  def inbox_conversations
    find_conversations(:folder_id => DefaultFolder.inbox.id, :trashed => false)
  end

  def sentbox_conversations
    find_conversations(:folder_id => DefaultFolder.sentbox.id, :trashed => false)
  end

  def draft_conversations
    find_conversations(:folder_id => DefaultFolder.drafts.id, :trashed => false)
  end

  def read_conversations(trashed = false)
    find_conversations(:read => true, :trashed => trashed)
  end

  def unread_conversations(trashed = false)
    find_conversations(:read => false, :trashed => trashed)
  end

  def trashed_conversations
    find_conversations(:trashed => true)
  end

  #TODO: Test this method
  def new_conversations
    find_conversations(:folder_id => DefaultFolder.inbox.id, :read => false, :trashed => false)
  end

  def flagged_conversations(flag = nil)
    if flag.nil?
      find_conversations(:custom => "flag is not NULL", :trashed => false)
    else
      find_conversations(:flag => flag, :trashed => false)
    end
  end

  def unflagged_conversations
    find_conversations(:custom => "flag is null", :trashed => false)
  end

  def conversations_count_in_folder(folder_name)
    folder_id = MessageFolder.get_folder_id(folder_name, self)
    find_conversations_count(:folder_id => folder_id, :trashed => false) if folder_id
  end

  def move_conversations_to_folder(conversation_ids, folder_name)
    if self.my_conversations?(conversation_ids)
      MessageConversation.move_selected_to_folder(conversation_ids, folder_name)
    end
  end

  def trash_conversations(conversation_ids, options={})
    options.store(:user_id, self.id)
    MessageConversation.trash_selected(conversation_ids, options)
  end

  def empty_trash
    failed = []
    trashed_conversations.each do |conversation|
      failed << conversation unless conversation.destroy
    end
    failed
  end

  def restore_trashed(conversation_ids = nil, options = {})
    conversation_ids = trashed_conversations.collect {|conv| conv.id} if conversation_ids.nil?
    options.store(:user_id, self.id)
    MessageConversation.restore_selected(conversation_ids, options)
  end

  def flag_conversations(conversation_ids, flag)
    if self.my_conversations?(conversation_ids)
      MessageConversation.set_selected_with_flag(conversation_ids, flag)
    end
  end

  def unflag_conversations(conversation_ids)
    if self.my_conversations?(conversation_ids)
      MessageConversation.clear_flag_from_selected(conversation_ids)
    end
  end

  def mark_conversations_as_read(conversation_ids)
    if self.my_conversations?(conversation_ids)
      MessageConversation.mark_selected_as_read(conversation_ids)
    end
  end

  def mark_conversations_as_unread(conversation_ids)
    if self.my_conversations?(conversation_ids)
      MessageConversation.mark_selected_as_unread(conversation_ids)
    end
  end

  def all_folders
    DefaultFolder.all + self.folders.sort_by {|folder| folder.name}
  end

  def all_folder_names
    all_folders.collect {|folder| folder.name}
  end

  def custom_folder_names
    folders.collect {|folder| folder.name}
  end

  def custom_templates
    templates.collect {|template| template}
  end
  
  def move_to_folder_options
    [DefaultFolder.inbox.name] + self.folders.collect {|folder| folder.name}.sort
  end

  def my_conversations?(conversation_ids)
    user = MessageConversation.get_user_having_conversations(conversation_ids)
    user == self
  end

  def can_access_folder?(folder_name)
    DefaultFolder.exists?(:name => folder_name) || my_folder?(folder_name)
  end

  # folder argument could be either a folder object or just the folder name
  def my_folder?(folder)
    if folder.is_a?(CustomFolder)
      folder.user == self
    else
      CustomFolder.exists?(:name => folder, :user_id => self.id)
    end
  end

  def email_notification_enabled?
    self.email_notification
  end

  def name_method
    self.messageable.class.messageable_name_field
  end

  def email_method
    self.messageable.class.messageable_email_field
  end

  def name
    self.messageable.send(self.name_method)
  end

  def email
    self.messageable.send(self.email_method)
  end

  private
  def send_message(message,action)
    invalid_message(message) unless message.is_a?(Message)
    message = message.instance_eval(action)
    message.sender = self
    message.recipients.delete(self) if action == 'reply_to_all'
    message
  end
  
  def invalid_message(message)
    raise "Invalid argument value for message: #{message}. Expects an instance of Message"
  end

  def sort_by_sender? param
    PluginConstants::SORT[:by][:from] == param
  end

  def construct_conditions options
    return options, {} if options.is_a?(Array) || options.is_a?(String)

    options = options.dup
    other_options = MessageConversation.sanitize_attributes!(options)

    return options, other_options if other_options[:custom].nil?

    conditions = Array.new
    values = Array.new
    options.each do |key,value|
      conditions << "#{key} = ?"
      values << value
    end

    custom = other_options[:custom]

    if custom.is_a?(String)
      conditions << other_options.delete(:custom)
    elsif custom.is_a?(Array)
      conditions << custom.shift
      values += custom
    end

    conditions = conditions.join(" AND ")
    conditions = [conditions] + values

    return conditions, other_options
  end
end
