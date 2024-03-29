def create_test_users
  User.create(:first_name => 'vignesh0', :hashed_password => 'vignesh', :email => 'vignesh_shanbhag+0@persistent.co.in')
  User.create(:first_name => 'vignesh1', :hashed_password => 'vignesh', :email => 'vignesh_shanbhag+1@persistent.co.in')
  User.create(:first_name => 'vignesh2', :hashed_password => 'vignesh', :email => 'vignesh_shanbhag+2@persistent.co.in')
  User.create(:first_name => 'vignesh3', :hashed_password => 'vignesh', :email => 'vignesh_shanbhag+3@persistent.co.in')
end

def create_default_folders
  DefaultFolder.create(:name => PluginConstants::INBOX, :status => MessageFolder::STATUS[:inbox])
  DefaultFolder.create(:name => PluginConstants::SENTBOX, :status => MessageFolder::STATUS[:sentbox])
  DefaultFolder.create(:name => PluginConstants::DRAFTS, :status => MessageFolder::STATUS[:drafts])
end

def create_default_templates
  DefaultTemplate.create(:title => "Happy Birthday", :message => "Happy birthday!! May all ur dreams and wishes cum true!! enjoy ur day ....... ")
  DefaultTemplate.create(:title => "Happy Birthday", :message => "May this birthday be just the beginning of a year filled with happy memories, wonderful moments and shinning dreams..")
  DefaultTemplate.create(:title => "Happy Friendship Day", :message => "Every nice frind is a gift of god...Its one of lifes best blessing, a priceless gift that can never b bought, sold,or forgotten..Just like you :)<br/>Happy Friendship Day :)")
  DefaultTemplate.create(:title => "Happy Friendship Day", :message => "A single candle can illuminate an entire room. A true friend lights up an entire lifetime. Thanks for the bright light of your friendship.<br/>Happy Friendship Day :)")
  DefaultTemplate.create(:title => "Happy Diwali", :message => "May the Divine Light of Diwali Spread into ur life peace, prosperity, and good health.<br/>Wishing You Happy Diwali")
  DefaultTemplate.create(:title => "Happy Diwali", :message => "Happy Diwali................");
  DefaultTemplate.create(:title => "Happy New Year", :message => "A Relaxed Mind, A Peaceful Soul, A Joyful Spirit, A Healthy Body & Heart full of Love..All these are my Prayers for You..Wish a Happy New Year! ")
  DefaultTemplate.create(:title => "Happy New Year", :message => "New is the year, new are the hopes and the aspirations, new is the resolution, new are the spirits and forever my warm wishes are for u.Have a promising and fulfilling new year.")
end

def create_template_categories
  TemplateCategory.create(:name =>"Birthday Cards")
  TemplateCategory.create(:name =>"Anniversary")
  TemplateCategory.create(:name =>"Engagement")
  TemplateCategory.create(:name =>"Graduation")
  TemplateCategory.create(:name =>"Moving")
  TemplateCategory.create(:name =>"New Baby")
  TemplateCategory.create(:name =>"Parties")
  TemplateCategory.create(:name =>"Wedding")
  TemplateCategory.create(:name =>"Summer")
  TemplateCategory.create(:name =>"Spring")
  TemplateCategory.create(:name =>"Thanksgiving")
  TemplateCategory.create(:name =>"Christmas")
  TemplateCategory.create(:name =>"New Year")
  TemplateCategory.create(:name =>"Valentine Day")
  TemplateCategory.create(:name =>"April Fools Day")
  TemplateCategory.create(:name =>"Earth Day")
  TemplateCategory.create(:name =>"Easter")
  TemplateCategory.create(:name =>"Mother's Day")
  TemplateCategory.create(:name =>"Father's Day")
  
end
  

create_test_users
create_default_folders
create_default_templates
create_template_categories