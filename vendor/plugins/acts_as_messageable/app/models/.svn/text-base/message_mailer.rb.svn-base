class MessageMailer < ActionMailer::Base
  def setup
  end

  def new_message_notification(recipient,sender)
    @subject = "New message recieved"
    @recipients = recipient.email
    @from = "abc.abc@example.com"
    @sent_on = Time.now
    @body['sender'] = sender
    @body["recipient"] = recipient
#    @body["url"] = 'http://'+url
  end

end
