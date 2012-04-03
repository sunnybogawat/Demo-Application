module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Messageable #:nodoc:
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_messageable(options = {})
          has_one :message_box, :as => :messageable, :dependent => :destroy

          cattr_accessor :messageable_name_field
          cattr_accessor :messageable_email_field

          self.messageable_name_field = options[:name_field] || 'name'
          self.messageable_email_field = options[:email_field] || 'email'

          after_create :create_message_box

          class_eval <<-EOV
            def create_message_box
              mb_user = MessageBox.new
              mb_user.messageable = self
              mb_user.save
            end
          EOV

          include ActiveRecord::Acts::Messageable::InstanceMethods
          extend ActiveRecord::Acts::Messageable::SingletonMethods
        end
      end
      
      module SingletonMethods
        def find_message_boxes_by_ids(messageable_ids)
          MessageBox.find_by_messageable_ids(messageable_ids, self.to_s)
        end

        def all_message_boxes
          MessageBox.find_by_messageable_type(self.to_s)
        end

        def message_box_ids(messageable_ids)
          find_message_boxes_by_ids(messageable_ids).collect {|msg_box| msg_box.id}
        end

        def possible_recipients_for_message(message)
          self.all #- [message.sender.messageable]
        end
      end

      module InstanceMethods
      end
    end
  end
end