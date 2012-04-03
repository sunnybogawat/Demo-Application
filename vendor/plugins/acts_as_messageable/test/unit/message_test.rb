require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MessageTest < ActiveSupport::TestCase
  load_schema
  fixtures :dummy_users, :message_boxes, :messages, :message_folders, :message_conversations

  def test_sanitize_attributes
    attributes = {
      :subject => "Test",
      :body => "Test message body",
      :sender => message_boxes(:user_1),
      :priority => 1,
      :recipients => [message_boxes(:user_2), message_boxes(:user_3)],
    }
    dummy_attrs = {
      :dummy_attr1 => "dummy_attr1 value",
      :dummy_attr2 => "dummy_attr2 value"
    }
    all_attributes = attributes.merge(dummy_attrs)
    assert_equal dummy_attrs, Message.sanitize_attributes!(all_attributes)
    assert_equal attributes, all_attributes
  end

  def test_post_sent_message
    message = messages(:already_sent)
    assert_raise(RuntimeError, "Invalid Action !!") { message.post }
  end

  def test_post_draft_without_recipients
    message = messages(:draft_wo_recpts)
    assert_raise(RuntimeError, "Invalid Action !!") { message.post }
  end

  def test_post_draft_with_recipients
    message = messages(:draft_with_recpts)
    assert message.saved_as_draft?
    assert_nothing_raised { message.post }
    assert_equal Message::SENT, message.status
    assert !message.conversations.empty?
    assert message.sent?
    assert message.sender.sentbox_conversations.include?(message.sentbox_conversation)
    assert message.sentbox_conversation.read
    assert_equal message.recipients.length, message.inbox_conversations.length
    for conv in message.inbox_conversations
      assert !conv.read
    end
  end

  def test_save_draft_when_already_sent
    message = messages(:already_sent)
    assert_raise(RuntimeError, "Invalid Action !!") {message.post}
  end

  def test_save_draft_saved_without_recipients
    message = messages(:draft_wo_recpts)
    assert_equal Message::DRAFT, message.status
    assert !message.conversations.empty?
    assert message.save_draft
    assert_equal Message::DRAFT, message.status
    assert !message.conversations.empty?
    assert message.draft_conversation.read
  end

  def test_save_new_message_as_draft
    message = Message.new(
      :subject => "New test message",
      :body => "This message is for testing save_draft functionality.",
      :sender => message_boxes(:user_1)
    )
    assert_nil message.flag
    assert message.conversations.empty?

    assert message.save_draft

    assert_equal Message::DRAFT, message.status
    assert !message.conversations.empty?
    assert message.draft_conversation
    assert message.draft_conversation.read
  end

  def test_reply_on_draft_message
    message = messages(:draft_with_recpts)
    assert_raise(RuntimeError, "Invalid Action !!") {message.reply}
  end

  def test_message_reply
    message = messages(:already_sent)
    expected_reply = Message.new(
      :subject => "RE: #{message.subject}",
      :body => (message.body.nil? ? nil : message.header << message.body),
      :recipients => [message.sender]
    )
    actual_reply = message.reply
    assert_equal expected_reply, actual_reply
  end

  def test_reply_to_all_on_draft_message
    message = messages(:draft_with_recpts)
    assert_raise(RuntimeError, "Invalid Action !!") {message.reply_to_all}
  end

  def test_message_reply_to_all
    message = messages(:already_sent)
    expected_reply_to_all = Message.new(
      :subject => "RE: #{message.subject}",
      :body => (message.body.nil? ? nil : message.header << message.body),
      :recipients => [message.sender] + message.recipients
    )

    actual_reply_to_all = message.reply_to_all
    assert_equal expected_reply_to_all, actual_reply_to_all
  end

  def test_forward_draft_message
    message = messages(:draft_with_recpts)
    assert_raise(RuntimeError, "Invalid Action !!") {message.forward}
  end

  def test_message_forward
    message = messages(:already_sent)
    expected_forward = Message.new(
      :subject => "FW: #{message.subject}",
      :body => (message.body.nil? ? nil : message.header << message.body)
    )

    actual_forward = message.forward
    assert_equal expected_forward, actual_forward
  end

  def test_message_header
    message = messages(:already_sent)
    expected_header = "<br/><br/><hr/><br/><b>From:</b> #{message.sender.name} (#{message.sender.email}) <br/><b>Sent:</b> #{message.created_at}\
      <br/><b>Subject:</b> #{message.subject}<br/><br/>"
    actual_header = message.header
    assert_equal expected_header, actual_header
  end

 def test_sent
    message = messages(:already_sent)
    assert_equal Message::SENT, message.status
    assert message.sent?

    message = messages(:draft_with_recpts)
    assert_not_equal Message::SENT, message.status
    assert !message.sent?
  end

  def test_saved_as_draft
    message = messages(:draft_with_recpts)
    assert_equal Message::DRAFT, message.status
    assert message.saved_as_draft?

    message = messages(:already_sent)
    assert_not_equal Message::DRAFT, message.status
    assert !message.saved_as_draft?
  end

  def test_message_comparision
    user_1 = message_boxes(:user_1)
    user_2 = message_boxes(:user_2)
    user_3 = message_boxes(:user_3)
    user_4 = message_boxes(:user_4)
    attributes = {
      :subject => "New test message",
      :body => "This message is for testing save_draft functionality.",
      :sender => user_2,
      :recipients => [user_1, user_4],
      :status => 1,
      :priority => 0
    }
    message1 = Message.new(attributes)
    message2 = Message.new(attributes)
    assert !message1.equal?(message2) # objects are not the same
    assert message1 == message2       # overridden method only checks for attributes to be same

    message1.subject += "Additional text"
    assert message1.save
    assert !(message1 == message2), message2.subject

    message1 = Message.new(attributes)
    message1.body += "Additional text"
    assert !(message1 == message2)

    message1 = Message.new(attributes)
    assert_equal Message::SENT, message1.status
    assert_equal message1.status, message2.status
    message1.status = Message::DRAFT
    assert !(message1 == message2)

    message1 = Message.new(attributes)
    assert_equal 0, message1.priority
    assert_equal message1.priority, message2.priority
    message1.priority += 1
    assert !(message1 == message2)

    message1 = Message.new(attributes)
    assert_nil message1.flag
    assert_equal message1.flag, message2.flag
    message1.flag = 1
    assert !(message1 == message2)

    message1 = Message.new(attributes)
    assert_equal user_2, message1.sender
    assert_equal message1.sender_id, message2.sender_id
    message1.sender = user_1
    assert !(message1 == message2)

    message1 = Message.new(attributes)
    assert message1.recipients.include?(user_1)
    assert message1.recipients.include?(user_4)
    assert !message1.recipients.collect {|recpt| recpt.id }.include?(user_3.id)
    message1.recipients << user_3
    assert !(message1 == message2)
  end

  def test_sent_message_inbox_conversations
    message = messages(:already_sent)
    expected_conversations = message.conversations.find(
      :all, :conditions => {:folder_id => DefaultFolder.inbox.id}
    ).sort_by {|conv| conv.id}
    actual_conversations = message.inbox_conversations.sort_by {|conv| conv.id}
    assert_equal expected_conversations, actual_conversations
    for recipient in message.recipients do
      assert message.inbox_conversations.collect {|conv| conv.user}.include?(recipient)
    end
    assert_equal message.recipients.length, message.inbox_conversations.length
  end

  def test_draft_message_has_no_inbox_conversations
    message = messages(:draft_with_recpts)
    assert message.inbox_conversations.empty?
  end

  def test_sent_message_sentbox_conversations
    message = messages(:already_sent)
    assert_not_nil message.sender
    assert_not_nil message.sentbox_conversation
    assert_equal message.sender, message.sentbox_conversation.user
  end

  def test_draft_message_has_no_sentbox_conversation
    message = messages(:draft_with_recpts)
    assert_nil message.sentbox_conversation
  end

  def test_draft_message_conversation
    message = messages(:draft_with_recpts)
    assert_not_nil message.sender
    assert_not_nil message.draft_conversation
    assert_equal message.sender, message.draft_conversation.user
  end

  def test_sent_message_has_no_draft_conversation
    message = messages(:already_sent)
    assert_nil message.draft_conversation
  end

  def test_new_message_has_no_inbox_conversations
    message = Message.new(
      :subject => "New test message",
      :body => "This message is for testing save_draft functionality.",
      :sender => message_boxes(:user_2),
      :recipients => [message_boxes(:user_1), message_boxes(:user_4)],
      :status => 0,
      :priority => 0
    )
    assert message.inbox_conversations.empty?
  end

  def test_new_message_has_no_sentbox_conversation
    message = Message.new(
      :subject => "New test message",
      :body => "This message is for testing save_draft functionality.",
      :sender => message_boxes(:user_2),
      :recipients => [message_boxes(:user_1), message_boxes(:user_4)],
      :status => 0,
      :priority => 0
    )
    assert_nil message.sentbox_conversation
  end

  def test_new_message_has_no_draft_conversation
    message = Message.new(
      :subject => "New test message",
      :body => "This message is for testing save_draft functionality.",
      :sender => message_boxes(:user_2),
      :recipients => [message_boxes(:user_1), message_boxes(:user_4)],
      :status => 0,
      :priority => 0
    )
    assert_nil message.draft_conversation
  end
end