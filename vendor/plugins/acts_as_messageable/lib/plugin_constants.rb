class PluginConstants
  INBOX = 'Inbox'
  SENTBOX = 'Sent'
  DRAFTS = 'Drafts'
  TRASH = 'Trash'
  PER_PAGE_OPTIONS = [1, 5, 10, 20, 50, 100]
  SORT = {
    :by => {
      :subject => "messages.subject",
      :from => "",
      :received => "message_conversations.created_at"
    },
    :order => {
      :asc => 'ASC',
      :desc => 'DESC'
    }
  }

  PRIORITIES = {1 => 'Confidential', 2 => 'High', 3 => 'Medium', 4 => 'Low', 0 =>'Normal' } #default 0
  FLAGS = {1 => 'Important', 2 => 'Notice', 3 => 'Todo', 4 => 'Favourite', 0 => 'Normal'}#default 0
end
