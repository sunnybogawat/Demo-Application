require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MessageBoxTest < ActiveSupport::TestCase
  load_schema
  fixtures :dummy_users, :message_boxes, :messages, :message_folders, :message_conversations
  
  def test_compose_message
    user = message_boxes(:user_1)
    expected = Message.new(:sender_id => user.id)
    actual = user.compose_message
    assert_equal expected, actual
  end

  def test_compose_message_reply
    user = message_boxes(:user_1)
    message = user.received_messages.find(:first,:conditions=>{:status => 1})
    assert_not_nil message
    expected_reply = Message.new(
      :subject => "RE: #{message.subject}",
      :body => (message.body.nil? ? nil : message.header << message.body),
      :sender_id => user.id,
      :recipients => [message.sender]
    )
    actual_reply = user.compose_message_reply(message)
    assert_equal expected_reply, actual_reply
  end

  def test_compose_reply_to_invalid_message
    user = message_boxes(:user_1)
    message = 'invalid message argument'
    assert !message.is_a?(Message)
    assert_raise(RuntimeError) {user.compose_message_reply(message)}
  end

  def test_compose_message_forward
    user = message_boxes(:user_1)
    message = user.received_messages.find(:first,:conditions=>{:status => 1})
    assert_not_nil message
    expected_forward = Message.new(
      :subject => "FW: #{message.subject}",
      :body => (message.body.nil? ? nil : message.header << message.body),
      :sender => user
    )
    actual_forward = user.compose_message_forward(message)
    assert_equal expected_forward, actual_forward
  end
#
  def test_compose_forward_to_invalid_message
    user = message_boxes(:user_1)
    message = 'invalid message argument'
    assert !message.is_a?(Message)
    assert_raise(RuntimeError) {user.compose_message_forward(message)}
  end

  def test_compose_message_reply_to_all
    user = message_boxes(:user_1)
    message = user.received_messages.find(:first,:conditions=>{:status => 1})
    expected_reply_to_all = Message.new(
      :subject => "RE: #{message.subject}",
      :body => (message.body.nil? ? nil : message.header << message.body),
      :recipients => [message.sender] + message.recipients - [user],
      :sender => user
    )
    actual_reply_to_all = user.compose_message_reply_to_all(message)
    assert_equal expected_reply_to_all, actual_reply_to_all
  end

  def test_compose_reply_to_all_to_invalid_message
    user = message_boxes(:user_1)
    message = 'invalid message argument'
    assert !message.is_a?(Message)
    assert_raise(RuntimeError) {user.compose_message_reply_to_all(message)}
  end

  def test_user_post_new_message
    user = message_boxes(:user_1)
    recipients = [
      message_boxes(:user_2),
      message_boxes(:user_3)
    ]
    message = user.compose_message(
      :subject => "Test message",
      :body => "This is for the purpose of testing.",
      :recipients => recipients
    )
    assert user.post_message(message)
    assert message.sent?
    assert !message.sentbox_conversation.nil?
    assert !message.inbox_conversations.empty?
    assert_equal message.recipients.length, message.inbox_conversations.length
  end

  def test_user_post_draft_message
    user = message_boxes(:user_1)
    recipients = [
      message_boxes(:user_2),
      message_boxes(:user_3)
    ]
    message = user.draft_messages.first
    assert_not_nil message.draft_conversation
    assert message.sentbox_conversation.nil?
    assert message.inbox_conversations.empty?
    message.recipients = recipients
    assert user.post_message(message)
    assert_nil message.draft_conversation
    assert !message.sentbox_conversation.nil?
    assert !message.inbox_conversations.empty?
    assert_equal message.recipients.length, message.inbox_conversations.length
  end

  def test_user_post_message_invalid_argument
    user = message_boxes(:user_1)
    message = "invalid message"
    assert_raise(RuntimeError) { user.post_message(message) }
  end

  def test_inbox_conversations
    user = message_boxes(:user_1)
    expected = user.conversations.find(
      :all, :conditions => {:folder_id => DefaultFolder.inbox.id, :trashed => false}
    ).sort_by {|conv| conv.id}
    actual = user.inbox_conversations.sort_by {|conv| conv.id}
    assert_not_nil actual
    assert_equal expected, actual
  end

  def test_sentbox_conversations
    user = message_boxes(:user_1)
    expected = user.conversations.find(
      :all, :conditions => {:folder_id => DefaultFolder.sentbox.id, :trashed => false}
    ).sort_by {|conv| conv.id}
    actual = user.sentbox_conversations.sort_by {|conv| conv.id}
    assert_not_nil actual
    assert_equal expected, actual
  end

  def test_draft_conversations
    user = message_boxes(:user_1)
    expected = user.conversations.find(
      :all, :conditions => {:folder_id => DefaultFolder.drafts.id, :trashed => false}
    ).sort_by {|conv| conv.id}
    actual = user.draft_conversations.sort_by {|conv| conv.id}
    assert_not_nil actual
    assert_equal expected, actual
  end

  def test_read_conversations
    user = message_boxes(:user_1)
    expected = user.conversations.find(
      :all, :conditions => {:read => true, :trashed => false}
    ).sort_by {|conv| conv.id}
    actual = user.read_conversations.sort_by {|conv| conv.id}
    assert_not_nil actual
    assert_equal expected, actual
  end

  def test_unread_conversations
    user = message_boxes(:user_1)
    expected = user.conversations.find(
      :all, :conditions => {:read => false, :trashed => false}
    ).sort_by {|conv| conv.id}
    actual = user.unread_conversations.sort_by {|conv| conv.id}
    assert_not_nil actual
    assert_equal expected, actual
  end

  def test_trashed_conversations
    user = message_boxes(:user_1)
    expected = user.conversations.find(
      :all, :conditions => {:trashed => true}
    ).sort_by {|conv| conv.id}
    actual = user.trashed_conversations.sort_by {|conv| conv.id}
    assert_not_nil actual
    assert_equal expected, actual
  end

  def test_flagged_conversations_with_valid_argument
    user = message_boxes(:user_1)
    flag = 1
    expected = user.conversations.find(
      :all, :conditions => {:flag => flag, :trashed => false}
    ).sort_by {|conv| conv.id}
    actual = user.flagged_conversations(flag).sort_by {|conv| conv.id}
    assert_not_nil actual
    assert_equal expected, actual
  end

  def test_flagged_conversations_with_nil_argument
    user = message_boxes(:user_1)
    expected = user.conversations.find(
      :all, :conditions => "flag is not null and trashed = false"
    ).sort_by {|conv| conv.id}
    actual = user.flagged_conversations.sort_by {|conv| conv.id}
    assert_not_nil actual
    assert_equal expected, actual
  end

  def test_unflagged_conversations
    user = message_boxes(:user_1)
    expected = user.conversations.find(
      :all, :conditions => {:flag => nil}
    ).sort_by {|conv| conv.id}
    actual = user.unflagged_conversations.sort_by {|conv| conv.id}
    assert_not_nil actual
    assert_equal expected, actual
  end

  def test_conversations_in_default_folder
    user = message_boxes(:user_1)
    folder = DefaultFolder.inbox
    expected = user.conversations.find(
      :all, :conditions => {:folder_id => folder.id, :trashed => false}
    )
    actual = user.conversations_in_folder(folder.name)
    assert_equal expected, actual
  end

  def test_conversations_in_custom_folder
    user = message_boxes(:user_1)
    folder = CustomFolder.find(:first, :conditions => {:user_id => user.id})
    assert user.my_folder?(folder)
    expected = user.conversations.find(
      :all, :conditions => {:folder_id => folder.id, :trashed => false}
    )
    actual = user.conversations_in_folder(folder.name)
    assert_equal expected, actual
  end

  def test_conversations_count_in_folder
    user = message_boxes(:user_1)
    folder = CustomFolder.find(:first, :conditions => {:user_id => user.id})
    assert user.my_folder?(folder)
    expected = user.conversations.count(
      :all, :conditions => {:folder_id => folder.id, :trashed => false}
    )
    actual = user.conversations_count_in_folder(folder.name)
    assert_equal expected, actual
  end

  def test_move_conversations_to_folder
    user = message_boxes(:user_1)
    new_folder = CustomFolder.find(:first, :conditions => {:user_id => user.id})
    assert user.my_folder?(new_folder)
    conversations = user.inbox_conversations.first(3)
    conversation_ids = conversations.collect { |conv| conv.id }
    for id in conversation_ids
      conversation = MessageConversation.find(id)
      assert_equal user, conversation.user
      assert_equal DefaultFolder.inbox, conversation.folder
    end
    assert user.move_conversations_to_folder(conversation_ids, new_folder.name)
    for id in conversation_ids
      conversation = MessageConversation.find(id)
      assert_equal new_folder, conversation.folder
    end
  end

  def test_trash_conversations
    user = message_boxes(:user_1)
    conversations = user.inbox_conversations.first(3)
    conversation_ids = conversations.collect { |conv| conv.id }
    for id in conversation_ids
      conversation = MessageConversation.find(id)
      assert_equal user, conversation.user
      assert_equal DefaultFolder.inbox, conversation.folder
    end
    assert user.trash_conversations(conversation_ids)
    for id in conversation_ids
      conversation = MessageConversation.find(id)
      assert conversation.trashed
    end
  end

  def test_restore_trashed_conversations
    user = message_boxes(:user_1)
    conversations = user.trashed_conversations.first(2)
    conversation_ids = conversations.collect { |conv| conv.id }
    for id in conversation_ids
      conversation = MessageConversation.find(id)
      assert_equal user, conversation.user
      assert conversation.trashed
    end
    assert user.restore_trashed(conversation_ids)
    for id in conversation_ids
      conversation = MessageConversation.find(id)
      assert !conversation.trashed
    end
  end

  def test_empty_users_trash
    user = message_boxes(:user_1)
    conversations = user.conversations.find(:all, :conditions => {:trashed => true})
    assert !conversations.empty?
    assert user.empty_trash
    assert user.conversations.find(:all, :conditions => {:trashed => true}).empty?
    for id in conversations.collect {|conv| conv.id}
      assert !MessageConversation.exists?(id)
    end
  end

  def test_restore_trash
    user = message_boxes(:user_1)
    conversations = user.conversations.find(:all, :conditions => {:trashed => true})
    assert !conversations.empty?
    assert user.restore_trashed
    assert user.conversations.find(:all, :conditions => {:trashed => true}).empty?
    for id in conversations.collect {|conv| conv.id}
      assert MessageConversation.exists?(id)
      assert !MessageConversation.find(id).trashed
    end
  end

  def test_flag_conversations
    user = message_boxes(:user_1)
    flag = 1
    conversations = user.unflagged_conversations.first(2)
    conversation_ids = conversations.collect {|conv| conv.id}
    assert !conversations.empty?
    for conv in conversations
      assert_nil conv.flag
    end
    assert user.flag_conversations(conversation_ids, flag)
    for id in conversation_ids
      assert MessageConversation.exists?(id)
      assert_not_nil MessageConversation.find(id).flag
    end
  end

  def test_clear_flagged_conversations
    user = message_boxes(:user_2)
    conversations = user.flagged_conversations.first(2)
    conversation_ids = conversations.collect {|conv| conv.id}
    assert !conversations.empty?
    for conv in conversations
      assert_not_nil conv.flag
    end
    assert user.unflag_conversations(conversation_ids)
    for id in conversation_ids
      assert MessageConversation.exists?(id)
      assert_nil MessageConversation.find(id).flag
    end
  end

  def test_mark_conversations_as_read
    user = message_boxes(:user_1)
    conversations = user.unread_conversations.first(2)
    conversation_ids = conversations.collect {|conv| conv.id}
    assert !conversations.empty?
    for conv in conversations
      assert !conv.read
    end
    assert user.mark_conversations_as_read(conversation_ids)
    for id in conversation_ids
      assert MessageConversation.exists?(id)
      assert MessageConversation.find(id).read
    end
  end

  def test_mark_conversations_as_unread
    user = message_boxes(:user_1)
    conversations = user.read_conversations.first(2)
    conversation_ids = conversations.collect {|conv| conv.id}
    assert !conversations.empty?
    for conv in conversations
      assert conv.read
    end
    assert user.mark_conversations_as_unread(conversation_ids)
    for id in conversation_ids
      assert MessageConversation.exists?(id)
      assert !MessageConversation.find(id).read
    end
  end

  def test_user_owns_conversations
    user = message_boxes(:user_1)
    conversations = user.conversations.first(5)
    conversation_ids = conversations.collect {|conv| conv.id}
    assert !conversations.empty?
    for conv in conversations
      assert_equal user, conv.user
    end
    assert user.my_conversations?(conversation_ids)
  end

  def test_if_user_can_access_default_folder
    user = message_boxes(:user_1)
    folder = DefaultFolder.inbox
    assert user.can_access_folder?(folder.name)
  end

  def test_if_user_can_access_custom_folder
    user = message_boxes(:user_1)
    folder = user.folders.first
    assert user.can_access_folder?(folder.name)
  end

  def test_user_should_not_access_other_users_folder
    user1 = message_boxes(:user_1)
    user2 = message_boxes(:user_2)
    folder = user2.folders.first
    assert !user1.can_access_folder?(folder.name)
  end

  def test_user_owns_folder
    user = message_boxes(:user_1)
    folder = user.folders.first
    assert user.my_folder?(folder)
    assert user.my_folder?(folder.name)
  end

  def test_user_cannot_own_default_folder
    user = message_boxes(:user_1)
    folder = DefaultFolder.inbox
    assert !user.my_folder?(folder)
  end

  def test_user_cannot_own_other_users_folder
    user1 = message_boxes(:user_1)
    user2 = message_boxes(:user_2)
    folder = user2.folders.first
    assert !user1.my_folder?(folder.name)
  end

  def test_if_email_notification_enabled
    user = message_boxes(:user_1)
    assert user.email_notification
    assert_equal user.email_notification, user.email_notification_enabled?
    assert_same(user.email_notification, user.email_notification_enabled?)
  end

  def test_name_method_of_message_box_user
    user = message_boxes(:user_1)
    dummy_user = dummy_users(:duser_1)
    assert_equal dummy_user, user.messageable
    assert dummy_user.is_a?(DummyUser)
    assert_equal DummyUser.messageable_name_field, user.name_method
  end

  def test_email_method_of_message_box_user
    user = message_boxes(:user_1)
    dummy_user = dummy_users(:duser_1)
    assert_equal dummy_user, user.messageable
    assert dummy_user.is_a?(DummyUser)
    assert_equal DummyUser.messageable_email_field, user.email_method
  end

  def test_name
    user = message_boxes(:user_1)
    dummy_user = dummy_users(:duser_1)
    assert_equal dummy_user, user.messageable
    assert_equal dummy_user.name, user.name
  end

  def test_email
    user = message_boxes(:user_1)
    dummy_user = dummy_users(:duser_1)
    assert_equal dummy_user, user.messageable
    assert_equal dummy_user.email, user.email
  end
end
