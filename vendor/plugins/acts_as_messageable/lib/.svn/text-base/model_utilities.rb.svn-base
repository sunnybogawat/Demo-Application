module ModelUtilities

  def self.included(base)
    base.extend ClassMethods
    base.include_instance_methods
  end

  module ClassMethods
    def include_instance_methods
      include InstanceMethods
    end

    def sanitize_attributes!(attrs)
      object = self.new
      rejected = {}
      attrs.each_key do |key|
        if not(object.has_attribute?(key) || object.respond_to?(key))
          rejected[key] = attrs.delete(key)
        end
      end
      return rejected
      #TODO: What if the conversation responds to the key, but the key is a read_only attribute?
    end

    # returns the extracted attributes
    def extract_attributes(options)
      options = options.dup
      sanitize_attributes! options
      return options
    end
  end

  module InstanceMethods
  end
end