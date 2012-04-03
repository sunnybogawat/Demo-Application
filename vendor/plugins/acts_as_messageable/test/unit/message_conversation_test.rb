# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MessageConversationTest < ActiveSupport::TestCase
  load_schema
  fixtures :dummy_users, :message_boxes, :messages, :message_folders, :message_conversations

  def test_records_exist
    conversation_ids = [
      message_conversations(:conv_1).id,
      message_conversations(:conv_2).id,
      message_conversations(:conv_3).id
    ]
    for id in conversation_ids
      assert MessageConversation.exists?(id)
    end
    assert MessageConversation.records_exist?(conversation_ids)
  end

  def test_records_exist_with_invalid_arguments
    conversation_ids = 12345
    assert_raise(RuntimeError) {MessageConversation.records_exist?(conversation_ids)}
  end

  def test_records_exist_with_invalid_conversations
    conversation_ids = ['abc', 'xyz']
    for id in conversation_ids
      assert !MessageConversation.exists?(id)
    end
    assert !MessageConversation.records_exist?(conversation_ids)
  end

  def test_belong_to_same_user
    user = message_boxes(:user_1)
    conversations = user.conversations.first(3)
    for conv in conversations
      assert_equal user, conv.user
    end
    conversation_ids = conversations.collect { |conv| conv.id }
    assert MessageConversation.belong_to_same_user?(conversation_ids)
    assert MessageConversation.belong_to_same_user?(conversations)
  end

  def test_belong_to_same_user_with_conversations_of_diff_users
    user1 = message_boxes(:user_1)
    user2 = message_boxes(:user_2)
    conversations = user1.conversations.first(2) + user2.conversations.first(2)
    conversation_ids = conversations.collect { |conv| conv.id }
    assert !MessageConversation.belong_to_same_user?(conversation_ids)
    assert !MessageConversation.belong_to_same_user?(conversations)
  end

  def test_belong_to_same_user_with_invalid_argument
    conversation_ids = 12345
    assert_raise(RuntimeError) {MessageConversation.belong_to_same_user?(conversation_ids)}
  end

  def test_get_user_having_conversations
    user = message_boxes(:user_1)
    conversations = user.conversations.first(3)
    conversation_ids = conversations.collect {|conv| conv.id}
    assert_equal 3, conversations.length
    assert_equal user, MessageConversation.get_user_having_conversations(conversations)
    assert_equal user, MessageConversation.get_user_having_conversations(conversation_ids)
  end

  def test_get_user_for_conversations_belonging_to_diff_users
    user1 = message_boxes(:user_1)
    user2 = message_boxes(:user_2)
    conversations = user1.conversations.first(2) + user2.conversations.first(2)
    conversation_ids = conversations.collect { |conv| conv.id }
    assert_nil MessageConversation.get_user_having_conversations(conversations)
    assert_nil MessageConversation.get_user_having_conversations(conversation_ids)
  end

  def test_get_user_having_conversations_with_invalid_argument
    conversation_ids = 12345
    assert_raise(RuntimeError) {MessageConversation.get_user_having_conversations(conversation_ids)}
  end

  def test_move_to_custom_folder
    new_folder = message_folders(:custom_3)
    conversation = message_conversations(:conv_9)
    assert_equal DefaultFolder.inbox, conversation.folder
    assert conversation.move_to(new_folder.name)
    assert_equal new_folder, conversation.folder
  end
  
  def test_move_to_non_existing_folder
    dummy_folder_name = 'fake'
    conversation = message_conversations(:conv_9)
    assert_equal DefaultFolder.inbox, conversation.folder
    assert !conversation.move_to(dummy_folder_name)
    assert conversation.reload
    assert_not_equal dummy_folder_name, conversation.folder.name
  end

  def test_move_to_default_folder
    new_folder = DefaultFolder.inbox
    conversation = message_conversations(:conv_8)
    assert_not_equal new_folder, conversation.folder
    assert conversation.move_to(new_folder.name)
    assert_equal new_folder, conversation.folder
  end

  def test_move_trashed_conversations_to_custom_folder
    new_folder = message_folders(:custom_4)
    conversation = message_conversations(:conv_10)
    assert_equal DefaultFolder.inbox, conversation.folder
    assert conversation.trashed
    assert conversation.move_to(new_folder.name)
    assert_equal new_folder, conversation.folder
    assert !conversation.trashed
  end

  def test_move_to_folder_not_owned_by_conversation_user
    new_folder = message_folders(:custom_4)
    conversation = message_conversations(:conv_9)
    assert_equal DefaultFolder.inbox, conversation.folder
    assert_not_equal new_folder.user, conversation.user
    assert !conversation.move_to(new_folder.name)
    assert_not_equal new_folder, conversation.folder
  end

  def test_trash_conversation
    conversation = message_conversations(:conv_9)
    assert !conversation.trashed
    assert conversation.trash
    assert conversation.trashed
  end

  def test_trash_already_trashed_conversation
    conversation = message_conversations(:conv_10)
    assert conversation.trashed
    assert !conversation.trash
  end

  def test_restore_conversation
    conversation = message_conversations(:conv_10)
    assert_equal DefaultFolder.inbox, conversation.folder
    assert conversation.trashed
    assert conversation.restore
    assert_equal DefaultFolder.inbox, conversation.folder
    assert !conversation.trashed
  end

  def test_restore_conversation_not_trashed
    conversation = message_conversations(:conv_9)
    assert !conversation.trashed
    assert !conversation.restore
  end

  def test_mark_as_read
    conversation = message_conversations(:conv_9)
    assert !conversation.read
    assert conversation.mark_as_read
    assert conversation.read
  end

  def test_mark_as_unread
    conversation = message_conversations(:conv_8)
    assert conversation.read
    assert conversation.mark_as_unread
    assert !conversation.read
  end

  def test_set_flag
    flag = 1
    conversation = message_conversations(:conv_3)
    assert_nil conversation.flag
    assert conversation.set_flag(flag)
    assert_equal flag, conversation.flag
  end

  def test_clear_flag
    conversation = message_conversations(:conv_4)
    assert !conversation.flag.nil?
    assert conversation.clear_flag
    assert conversation.flag.nil?
  end

  def test_conversation_reply
    conversation = message_conversations(:conv_3)
    message = conversation.message
    expected_reply = Message.new(
      :subject => "RE: #{message.subject}",
      :body => (message.body.nil? ? nil : message.header << message.body),
      :sender => conversation.user,
      :recipients => [message.sender]
    )
    actual_reply = conversation.reply
    assert_equal expected_reply, actual_reply
  end

  def test_conversation_forward
    conversation = message_conversations(:conv_3)
    message = conversation.message
    expected_forward = Message.new(
      :subject => "FW: #{message.subject}",
      :body => (message.body.nil? ? nil : message.header << message.body),
      :sender => conversation.user
    )
    actual_forward = conversation.forward
    assert_equal expected_forward, actual_forward
  end

  def test_conversation_reply_to_all
    conversation = message_conversations(:conv_3)
    message = conversation.message
    expected_reply_to_all = Message.new(
      :subject => "RE: #{message.subject}",
      :body => (message.body.nil? ? nil : message.header << message.body),
      :recipients => [message.sender] + message.recipients - [conversation.user],
      :sender => conversation.user
    )
    actual_reply_to_all = conversation.reply_to_all
    assert_equal expected_reply_to_all, actual_reply_to_all
  end

  def test_trashed?
    conversation = message_conversations(:conv_10)
    conversation.trashed = true
    assert conversation.save
    assert conversation.trashed?
    conversation.trashed = false
    assert conversation.save
    assert !conversation.trashed?
  end

  def test_flagged?
    conversation = message_conversations(:conv_1)
    conversation.flag = nil
    assert conversation.save
    assert !conversation.flagged?
    conversation.flag = 1
    assert conversation.save
    assert conversation.flagged?
  end

  def test_trash_selected_conversations
    conversation_ids = [
      message_conversations(:conv_1).id,
      message_conversations(:conv_8).id,
      message_conversations(:conv_9).id
    ]
    for id in conversation_ids
      assert !MessageConversation.find(id).trashed?
    end
    invalid_ids, invalid_action_ids = MessageConversation.trash_selected(conversation_ids)
    assert invalid_ids.empty?
    for id in conversation_ids
      assert MessageConversation.find(id).trashed?
    end
  end

  def test_invalid_argument_trash_selected_raise_exception
    conversation_ids = '12345'
    assert !conversation_ids.is_a?(Array)
    assert_raise(RuntimeError) {MessageConversation.trash_selected(conversation_ids)}
  end

  def test_trash_only_valid_selected_conversations
    conversation_ids = [
      message_conversations(:conv_1).id,
      message_conversations(:conv_8).id,
      message_conversations(:conv_9).id
    ]
    for id in conversation_ids
      assert !MessageConversation.find(id).trashed?
    end
    expected_invalid_ids = [123, 456]
    conversation_ids += expected_invalid_ids
    actual_invalid_ids, invalid_action_ids = MessageConversation.trash_selected(conversation_ids)
    assert_equal expected_invalid_ids, actual_invalid_ids
    for id in (conversation_ids - expected_invalid_ids)
      assert MessageConversation.find(id).trashed?
    end
  end

  def test_trash_already_trashed_conversations
    conversation_ids = [
      message_conversations(:conv_6).id,
      message_conversations(:conv_10).id
    ]
    for id in conversation_ids
      assert MessageConversation.find(id).trashed?
    end
    invalid_ids, invalid_action_ids = MessageConversation.trash_selected(conversation_ids)
    assert_equal conversation_ids, invalid_action_ids
  end

  def test_restore_selected_conversations
    conversation_ids = [
      message_conversations(:conv_6).id,
      message_conversations(:conv_10).id
    ]
    for id in conversation_ids
      assert MessageConversation.find(id).trashed?
    end
    invalid_ids, invalid_action_ids = MessageConversation.restore_selected(conversation_ids)
    assert invalid_ids.empty?
    for id in conversation_ids
      assert !MessageConversation.find(id).trashed?
    end
  end

  def test_invalid_arguement_restore_selected_raise_exception
    conversation_ids = '12345'
    assert !conversation_ids.is_a?(Array)
    assert_raise(RuntimeError) {MessageConversation.restore_selected(conversation_ids)}
  end

  def test_restore_only_valid_selected_conversations
    conversation_ids = [
      message_conversations(:conv_6).id,
      message_conversations(:conv_10).id
    ]
    for id in conversation_ids
      assert MessageConversation.find(id).trashed?
    end
    expected_invalid_ids = [123, 456]
    conversation_ids += expected_invalid_ids
    actual_invalid_ids, invalid_action_ids = MessageConversation.restore_selected(conversation_ids)
    assert_equal expected_invalid_ids, actual_invalid_ids
    for id in (conversation_ids - expected_invalid_ids)
      assert !MessageConversation.find(id).trashed?
    end
  end

  def test_restore_selected_conversations_not_trashed
    conversation_ids = [
      message_conversations(:conv_1).id,
      message_conversations(:conv_8).id,
      message_conversations(:conv_9).id
    ]
    for id in conversation_ids
      assert !MessageConversation.find(id).trashed?
    end
    invalid_ids, invalid_action_ids = MessageConversation.restore_selected(conversation_ids)
    assert_equal conversation_ids, invalid_action_ids
  end

  def test_move_selected_to_folder
    conversation_ids = [
      message_conversations(:conv_9).id,
      message_conversations(:conv_13).id
    ]
    for id in conversation_ids
      assert_equal DefaultFolder.inbox, MessageConversation.find(id).folder
    end
    new_folder = message_folders(:custom_3)
    assert MessageFolder.exists?(new_folder)
    invalid_ids, invalid_action_ids  = MessageConversation.move_selected_to_folder(conversation_ids, new_folder.name)
    assert invalid_ids.empty?
    for id in conversation_ids
      assert_equal new_folder, MessageConversation.find(id).folder
    end
  end

  def test_invalid_argument_move_selected_raise_exception
    conversation_ids = '12345'
    assert !conversation_ids.is_a?(Array)
    new_folder = message_folders(:custom_3)
    assert_raise(RuntimeError) {MessageConversation.move_selected_to_folder(conversation_ids, new_folder.name)}
  end

  def test_move_invalid_conversations_selected_to_folder
    conversation_ids = [
      message_conversations(:conv_9).id,
      message_conversations(:conv_13).id
    ]
    for id in conversation_ids
      assert_equal DefaultFolder.inbox, MessageConversation.find(id).folder
    end
    expected_invalid_ids = [123, 456]
    conversation_ids += expected_invalid_ids
    new_folder = message_folders(:custom_3)
    assert MessageFolder.exists?(new_folder)
    actual_invalid_ids, invalid_action_ids  = MessageConversation.move_selected_to_folder(conversation_ids, new_folder.name)
    assert_equal expected_invalid_ids, actual_invalid_ids
    for id in (conversation_ids - expected_invalid_ids)
      assert_equal new_folder, MessageConversation.find(id).folder
    end
  end

  def test_move_selected_to_invalid_folder
    conversation_ids = [
      message_conversations(:conv_9).id,
      message_conversations(:conv_13).id
    ]
    for id in conversation_ids
      assert_equal DefaultFolder.inbox, MessageConversation.find(id).folder
    end
    fake_folder_name = "fake_folder"
    assert_raise(RuntimeError, "Invalid Folder !!") do
      MessageConversation.move_selected_to_folder(conversation_ids, fake_folder_name)
    end
    for id in conversation_ids
      assert_equal DefaultFolder.inbox, MessageConversation.find(id).folder
    end
  end

  def test_mark_selected_conversations_as_read
    conversation_ids = [
      message_conversations(:conv_12),
      message_conversations(:conv_13),
      message_conversations(:conv_14)
    ]
    for id in conversation_ids
      assert !MessageConversation.find(id).read
    end
    invalid_ids, invalid_action_ids  = MessageConversation.mark_selected_as_read(conversation_ids)
    assert invalid_ids.empty?
    for id in conversation_ids
      assert MessageConversation.find(id).read
    end
  end

  def test_invalid_arguement_mark_selected_as_read_raise_exception
    conversation_ids = '12345'
    assert !conversation_ids.is_a?(Array)
    assert_raise(RuntimeError) {MessageConversation.mark_selected_as_read(conversation_ids)}
  end

  def test_mark_selected_invalid_conversations_as_read
    conversation_ids = [
      message_conversations(:conv_12),
      message_conversations(:conv_13),
      message_conversations(:conv_14)
    ]
    expected_invalid_ids = [123, 456]
    for id in conversation_ids
      assert !MessageConversation.find(id).read
    end
    conversation_ids += expected_invalid_ids
    actual_invalid_ids, invalid_action_ids  = MessageConversation.mark_selected_as_read(conversation_ids)
    assert_equal expected_invalid_ids, actual_invalid_ids
    for id in (conversation_ids - expected_invalid_ids)
      assert MessageConversation.find(id).read
    end
  end

  def test_mark_selected_read_conversations_as_unread
    conversation_ids = [
      message_conversations(:conv_7),
      message_conversations(:conv_8),
      message_conversations(:conv_11)
    ]
    for id in conversation_ids
      assert MessageConversation.find(id).read
    end
    invalid_ids = MessageConversation.mark_selected_as_unread(conversation_ids)
    assert invalid_ids.empty?
    for id in conversation_ids
      assert !MessageConversation.find(id).read
    end
  end

  def test_invalid_arguement_mark_selected_as_unread_raise_exception
    conversation_ids = '12345'
    assert !conversation_ids.is_a?(Array)
    assert_raise(RuntimeError) {MessageConversation.mark_selected_as_unread(conversation_ids)}
  end

  def test_mark_selected_invalid_conversations_as_unread
    conversation_ids = [
      message_conversations(:conv_7),
      message_conversations(:conv_8),
      message_conversations(:conv_11)
    ]
    for id in conversation_ids
      assert MessageConversation.find(id).read
    end
    expected_invalid_ids = [123, 456]
    conversation_ids += expected_invalid_ids
    actual_invalid_ids = MessageConversation.mark_selected_as_unread(conversation_ids)
    assert_equal expected_invalid_ids, actual_invalid_ids
    for id in (conversation_ids - actual_invalid_ids)
      assert !MessageConversation.find(id).read
    end
  end

  def test_set_flag_on_selected_conversations
    conversation_ids = [
      message_conversations(:conv_7),
      message_conversations(:conv_8),
      message_conversations(:conv_9)
    ]
    flag = 1
    for id in conversation_ids
      assert_nil MessageConversation.find(id).flag
    end
    invalid_ids, invalid_action_ids = MessageConversation.set_selected_with_flag(conversation_ids, flag)
    assert invalid_ids.empty?
    for id in conversation_ids
      assert_not_nil MessageConversation.find(id).flag
    end
  end

  def test_invalid_arguement_set_flag_on_selected_raise_exception
    conversation_ids = '12345'
    assert !conversation_ids.is_a?(Array)
    flag = 1
    assert_raise(RuntimeError) {MessageConversation.set_selected_with_flag(conversation_ids, flag)}
  end

  def test_set_flag_on_selected_invalid_conversations
    conversation_ids = [
      message_conversations(:conv_7),
      message_conversations(:conv_8),
      message_conversations(:conv_9)
    ]
    flag = 1
    for id in conversation_ids
      assert_nil MessageConversation.find(id).flag
    end
    expected_invalid_ids = [123, 456]
    conversation_ids += expected_invalid_ids
    actual_invalid_ids, invalid_action_ids = MessageConversation.set_selected_with_flag(conversation_ids, flag)
    assert_equal expected_invalid_ids, actual_invalid_ids
    for id in (conversation_ids - actual_invalid_ids)
      assert_not_nil MessageConversation.find(id).flag
    end
  end

  def test_set_flag_on_selected_trashed_conversations
    conversation_ids = [
      message_conversations(:conv_6).id,
      message_conversations(:conv_10).id
    ]
    flag = 1
    for id in conversation_ids
      assert_nil MessageConversation.find(id).flag
    end
    invalid_ids, invalid_action_ids = MessageConversation.set_selected_with_flag(conversation_ids, flag)
    assert_equal conversation_ids, invalid_action_ids
    for id in conversation_ids
      assert_nil MessageConversation.find(id).flag
    end
  end

  def test_clear_flag_from_selected_conversations
    conversation_ids = [
      message_conversations(:conv_2),
      message_conversations(:conv_4)
    ]
    for id in conversation_ids
      assert_not_nil MessageConversation.find(id).flag
    end
    invalid_ids, invalid_action_ids = MessageConversation.clear_flag_from_selected(conversation_ids)
    assert invalid_ids.empty?
    for id in conversation_ids
      assert_nil MessageConversation.find(id).flag
    end
  end

  def test_invalid_arguement_clear_flag_from_selected_raise_exception
    conversation_ids = '12345'
    assert !conversation_ids.is_a?(Array)
    flag = 1
    assert_raise(RuntimeError) {MessageConversation.clear_flag_from_selected(conversation_ids)}
  end

  def test_clear_flag_from_selected_invalid_conversations
    conversation_ids = [
      message_conversations(:conv_2),
      message_conversations(:conv_4)
    ]
    for id in conversation_ids
      assert_not_nil MessageConversation.find(id).flag
    end
    expected_invalid_ids = [123, 456]
    conversation_ids += expected_invalid_ids
    actual_invalid_ids, invalid_action_ids = MessageConversation.clear_flag_from_selected(conversation_ids)
    assert_equal expected_invalid_ids, actual_invalid_ids
    for id in (conversation_ids - actual_invalid_ids)
      assert_nil MessageConversation.find(id).flag
    end
  end

  def test_clear_flag_from_selected_trashed_conversations
    conversation_ids = [
      message_conversations(:conv_15).id,
      message_conversations(:conv_16).id,
      message_conversations(:conv_17).id
    ]
    for id in conversation_ids
      assert_not_nil MessageConversation.find(id).flag
    end
    invalid_ids, invalid_action_ids = MessageConversation.clear_flag_from_selected(conversation_ids)
    assert_equal conversation_ids, invalid_action_ids
    for id in conversation_ids
      assert_not_nil MessageConversation.find(id).flag
    end
  end
end
