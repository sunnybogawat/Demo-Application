class CustomFolder < MessageFolder
  belongs_to :user, :class_name => 'MessageBox'
  # *Description*
  # * Checks whether the folder is owned by the given user
  # *Parameters*
  # * user - Instance of MessageBox class
  # *Returns*
  # * boolean - True if user is the owner of the folder, False otherwise
  def owned_by?(user)
    user == self.user
  end
end
