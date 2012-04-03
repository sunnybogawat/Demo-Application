require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ActsAsMessageableTest < ActiveSupport::TestCase

  load_schema

  def test_messages
    assert_equal([], Message.all)
    assert_kind_of Message, Message.new
  end
end
