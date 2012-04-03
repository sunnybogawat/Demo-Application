class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => 'MessageBox'
  has_and_belongs_to_many :recipients, :foreign_key => 'message_id', :association_foreign_key => 'recipient_id',
    :class_name => 'MessageBox', :join_table => 'message_recipients'
  has_many :conversations, :class_name => 'MessageConversation', :dependent => :destroy

  validates_presence_of :subject, :sender
  #  validates_presence_of :recipients, :if => :recipients_validation_required?
  validates_length_of :subject, :maximum => 100

  include ModelUtilities

  DRAFT = 0
  SENT = 1
  REPLY = 'reply'
  REPLY_ALL = 'replyall'
  FORWARD = 'forward'
  NEW = 'new'
  EDIT = 'edit'

  class << self

    # *Description*
    # * Fetches a Message record when attrs is Integer id. When attrs is passed a
    # hash of attributes the method returns creates a new record with those attributes
    # *Parameters*
    # * attrs - Integer Id or hash of Message attributes
    # *Returns*
    # * Message - a new record if hash is passed else the existing record from database
    # *Exceptions*
    # * RecordNotFound - when attrs is neither a Hash nor a valid id
    def find_or_create(attrs)
      if attrs.is_a?(Hash)
        sanitize_attributes!(attrs)
        return self.new(attrs)
      else # argument could be the message id
        return self.find(attrs) rescue nil unless attrs.blank?
      end
    end
  end

  # *Description*
  # * Posts the message to its intended recipients. Recipients must already be specified.
  # *Parameters*
  # * options - Hash of options. Currently options can include MessageConversation attributes
  # *Returns*
  # * False - if message posting fails
  # *Exceptions*
  # * RecordNotFound - when attrs is neither a Hash nor a valid id
  def post(options = {})
    raise invalid_action if self.sent?
    raise invalid_recipients if self.recipients.empty?
    # The first (additional) save is required for making database id available for
    # creating conversations which need it as the foreign key (it cannot be null)
    # The save inside the 'transaction' block will not be commited to the database
    # until all the queries are successfully executed, thus keeping the message object
    # deprived of a database id. As such when conversations are being created the message
    # will not have any id associated with it.
    
    if self.save
      transaction do
        delete_draft_conversation if self.saved_as_draft?
        self.status = Message::SENT
        self.save # this is required to save the new status
        create_sent_conversations(options)
      end
    end
  end

  # *Description*
  # * Saves the draft version of the message. Recipients are not necessary when saving
  # draft
  # *Parameters*
  # * options - Hash of options. Currently options can include conversation attributes
  # *Returns*
  # * False - if message saving fails
  # *Exceptions*
  # * RuntimeError - if the message is already sent
  #TODO: Check what this method returns. Should it return MessageBox???
  def save_draft(options = {})
    raise invalid_action if self.sent?
    self.status = Message::DRAFT
    attrs = Message.extract_attributes(options)

    self.attributes = attrs if attrs.is_a?(Hash)

    if self.save
      new_message? ? create_draft_conversation(options): edit_draft_conversation(options)
    end
  end

  # the reply, forward and reply_to_all methods will add the sender and all the recipients of the message
  # to the recipients Array of the reply/forward. It cannot be determined in these methods which
  # of the recipients of the message is actually composing the reply/forward as the users can
  # only manipulate the conversations and not the actual messages. Thus the actual
  # composer of the reply has to be deleted from the recipients Array  and added as the sender in the \
  # reply, forward and reply_to_all methods of the Conversation class.

  # *Description*
  # * Used for composing a 'reply' for a message. It returns a Message instance pre-initialized
  # with the subject, body and recipient details. The sender cannot be initialized here
  # as which user is composing this 'reply' is not known inside the Message class.
  # The message must have SENT status.
  # *Parameters*
  # * NONE
  # *Returns*
  # * New Message
  # *Exceptions*
  # * RuntimeError if the given message is a draft
  def reply
    raise invalid_action if self.saved_as_draft?
    Message.new(
      :subject => "RE: #{self.subject}",
      :body => (self.body.nil? ? nil : self.header << self.body),
      :recipients => [self.sender]
    )
  end

  # *Description*
  # * Used for composing a 'forward' for a message. It returns a Message instance pre-initialized
  # with the subject and body. The sender cannot be initialized here as which user is composing
  # this 'forward' is not known inside the Message class.
  # The message must have SENT status.
  # *Parameters*
  # * NONE
  # *Returns*
  # * New Message
  # *Exceptions*
  # * RuntimeError if the given message is a draft
  def forward
    raise invalid_action if self.saved_as_draft?
    Message.new(
      :subject => "FW: #{self.subject}",
      :body => (self.body.nil? ? nil : self.header << self.body)
    )
  end

  # *Description*
  # * Used for composing a 'reply all' for a message. It returns a Message instance pre-initialized
  # with the subject, body and recipients. The sender cannot be initialized here as which user is composing
  # this 'reply all' is not known inside the Message class.
  # The message must have SENT status.
  # *Parameters*
  # * NONE
  # *Returns*
  # * New Message
  # *Exceptions*
  # * RuntimeError if the given message is a draft
  def reply_to_all
    raise invalid_action if self.saved_as_draft?
    message = self.reply
    message.recipients += self.recipients
    message
  end

  #  def possible_recipients
  #    raise "Message sender is not set!" if self.sender.nil?
  #    MessageBox.all - [self.sender]
  #  end

  # *Description*
  # * Returns an array of messageable users of the message. The messageable user is an
  # instance of the class to which the message box is attached. The messageable user
  # could be an instance of class User, Employee, Person etc, which acts as messageable.
  # *Parameters*
  # * NONE
  # *Returns*
  # * Array of messageable users
  # *Exceptions*
  # * NONE
  def messageable_recipients
    self.recipients.collect { |recipient| recipient.messageable }
  end

  # *Description*
  # * Returns a html formatted string that contains the message sender's name and email,
  # time the message was sent and the message subject. This will generate the following
  # eg.
  #   -----------------------------------------
  #   From: NAME (name@domain.com)
  #   Sent: DATE TIME
  #   Subject: MESSAGE SUBJECT
  # *Parameters*
  # * NONE
  # *Returns*
  # * String
  # *Exceptions*
  # * NONE
  def header
    "<br/><br/><hr/><br/><b>From:</b> #{self.sender.name} (#{self.sender.email}) <br/><b>Sent:</b> #{self.created_at}\
      <br/><b>Subject:</b> #{self.subject}<br/><br/>"
  end

  #  def to_string
  #    "<b>From:</b> #{self.sender.name} (#{self.sender.email}) <br/><b>Sent:</b> #{self.created_at}<br/><b>Subject:</b> #{self.subject}\
  #      <br/><br/>#{self.body}"
  #  end

  # *Description*
  # * Checks whether the message is sent or not
  # *Parameters*
  # * NONE
  # *Returns*
  # * Boolean
  # *Exceptions*
  # * NONE
  def sent?
    self.status == Message::SENT
  end

  def saved_as_draft?
    self.status == Message::DRAFT && !self.conversations.empty?
  end

  def saved_as_draft_without_conversation?
    self.status == Message::DRAFT && self.conversations.empty?
  end

  def new_message?
    self.id.nil? || !Message.exists?(self.id) || !MessageConversation.exists?(:message_id => self.id)
  end

  def ==(message)
    self.class == message.class && self.subject == message.subject &&
      self.body == message.body && self. status == message.status &&
      self.priority == message.priority && self.flag == message.flag &&
      self.sender_id == message.sender_id && self.recipients == message.recipients
  end

  #TODO not required
  def inbox_conversations
    self.conversations.find(:all, :conditions => {:folder_id => DefaultFolder.inbox.id})
  end

  #TODO not required
  def sentbox_conversation
    self.conversations.find(:first, :conditions => {:folder_id => DefaultFolder.sentbox.id})
  end

  def draft_conversation
    self.conversations.find(:first, :conditions => {:folder_id => DefaultFolder.drafts.id})
  end

  def create_conversation(options = {})
    MessageConversation.sanitize_attributes!(options)
    self.conversations.create(options)
  end

  def create_draft_conversation(options = {})
    options.store(:folder_id, DefaultFolder.drafts.id)
    options.store(:user_id, self.sender.id)
    options.store(:read, true)
    create_conversation(options)
  end

  def edit_draft_conversation(options)
    conversation = self.draft_conversation
    conversation.flag = options[:flag] if options.has_key?(:flag)
    conversation.save
  end

  def delete_draft_conversation
    self.draft_conversation.destroy
  end

  def create_sent_conversations(options = {})
    options.merge!(
      :folder_id => DefaultFolder.sentbox.id,
      :user_id => self.sender.id,
      :read => true
    )
    create_conversation(options)

    #TODO: Appropriately split this method. Currently it is creating both sentbox and inbox conversations
    create_recipients_conversations(options)
  end

  def create_recipients_conversations(options = {})
    options[:read] = false
    options[:folder_id] = DefaultFolder.inbox.id
    self.recipients.each do |recipient|
      options[:user_id] = recipient.id
      create_conversation(options)
      send_email_notification(recipient,self.sender) if recipient.email_notification_enabled?
    end
  end

  def send_email_notification(recipient,sender)
    MessageMailer.new_message_notification(recipient,sender).deliver
  end

  def invalid_action
    "Invalid Action !!"
  end

  def invalid_recipients
    "No Recipients selected for the message!!"
  end
end
