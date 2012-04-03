class User < ActiveRecord::Base
  acts_as_messageable

  def name
    self.first_name + " " + self.last_name
  end
end
