class ApplicationController < ActionController::Base
  protect_from_forgery

  #acts_as_messageable plugin require current_user method.
  def current_user
    return User.where(:first_name=>'vignesh0').first
  end
end
