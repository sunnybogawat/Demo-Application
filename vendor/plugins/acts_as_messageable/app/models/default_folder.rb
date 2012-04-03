require 'plugin_constants'

class DefaultFolder < MessageFolder

  class << self

    # *Description*
    # * Fetches the inbox folder from database
    # *Parameters*
    # * NONE
    # *Returns*
    # * MessageFolder - if record for inbox exists in database
    # * nil - if record for inbox doesn't exist
    def inbox
      find(:first, :conditions => {:status => MessageFolder::STATUS[:inbox]})
    end

    # *Description*
    # * Fetches the sentbox folder from database
    # *Parameters*
    # * NONE
    # *Returns*
    # * MessageFolder - if record for sentbox exists in database
    # * nil - if record for sentbox doesn't exist
    def sentbox
      find(:first, :conditions => {:status => MessageFolder::STATUS[:sentbox]})
    end

    # *Description*
    # * Fetches the drafts folder from database
    # *Parameters*
    # * NONE
    # *Returns*
    # * MessageFolder - if record for drafts exists in database
    # * nil - if record for drafts doesn't exist
    def drafts
      find(:first, :conditions => {:status => MessageFolder::STATUS[:drafts]})
    end

    # *Description*
    # * Returns a hash of the default folder names
    # *Parameters*
    # * NONE
    # *Returns*
    # * Hash
    def name_hash
      {:inbox => inbox.name, :sentbox => sentbox.name, :drafts => drafts.name}
    end

    # *Description*
    # * Returns the names of the default folders whose conversations cannot be moved
    # to other folders except trash
    # *Parameters*
    # * NONE
    # *Returns*
    # * Array of folder names (strings)
    def immovables
      [sentbox.name, drafts.name]
    end
  end
end