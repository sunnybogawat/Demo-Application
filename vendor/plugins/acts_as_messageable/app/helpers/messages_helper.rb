module MessagesHelper

  # This method is added for testing this plugin (please remove)
  def current_user
    return User.where(:first_name=>'vignesh0').first
  end


  # This method used to display  sort link for header of list
  # Parameters:
  # * text :  link text
  # * param: name of column on which sorting should be done
  def sort_link_helper(text, param)
    params.delete(:action)
    key = param
    key += "_reverse" if params[:sort] == param
    options = {
      :url => {:action => 'list', :params => params.merge({:id=> current_user.id,:sort => key, :page => nil, :folder_name => @folder_name})},
      :update => 'pms_tabs_contents',
    }
    html_options = {
      :title => "Sort by this field",
    }
    link_to_remote(text, options, html_options)
  end

  # This method used to display user name as link in messages list
  # Parameters:
  # * id :  user id
  # * rec_id: conversation id
  # * action:  action name for link(edit/show)
  def name_link_helper(id, rec_id, action)
    if action == 'show'
      action = user_message_path(current_user.id, rec_id)
    else
      action = edit_user_message_path(current_user.id, rec_id)
    end
    text = get_name(id)
    name = (text.blank?)? '............' : text
    new_name =  truncate(name, :length => 20)
    html_options = {
      :title => name,
    }
    link_to(new_name, action, html_options)
  end
  
  # This method used to display subject as link in messages list
  # Parameters:
  # * text :  subject text of message
  # * rec_id: conversation id
  # * action:  action name for link(edit/show)
  def subject_link_helper(text, rec_id, action)
    if action == 'show'
      action = user_message_path(current_user.id, rec_id)
    else
      action = edit_user_message_path(current_user.id, rec_id)
    end
    subject = (text.nil? || '' == text) ? '.............' : text
    new_subject =  subject.length > 30 ? subject.slice(0..29) + '...' : subject
    html_options = {
      :title => subject,
    }
    link_to(new_subject, action, html_options)
  end
  
  # This method returns name of user in format of 'first_name last_name'
  # Parameters:
  # * id :  user id
  def get_name(id)
    return "" if !id
    user = User.find(id)
    user.first_name + ' ' + user.last_name
  end
  
  # This method displays error messages for forms.
  # Parameters:
  # * message : object of messgae with all values and errors hash 
  def error_messages_for_message(message)
    if message and !message.errors.empty? 
      str = '<div style="margin:5px;color:red;border:1px solid red;">'
      message.errors.each do |key, val|
        str += '<b> * '+ key.to_s.capitalize + '</b>: '+ val +' <br/>'
      end 
      str += '</div>'
    end
    str.html_safe unless str.blank?
  end

  def post_user_message_path(user_id, conversation_id=nil)
    conversation_id ||= 'new'
    "#{conversation_id}/send"
  end

  def move_to_options
    folder_names = @message_box.move_to_folder_options

    folder_names -= [session[:folder]]

    options = Array.new
    folder_names.each_with_index do |name, index|
      options[index] = ["Move to #{name}", "move_to_#{name}"]
    end

    DefaultFolder.immovables.include?(session[:folder]) ? [] : options
  end

  def bulk_actions_selection
    options = [['Other Actions', ''], ['Mark as Read','mark_as_read'], ['Mark as Unread','mark_as_unread']]
    options += move_to_options
    select_tag('bulk_actions', options_for_select(options),
      :onchange => "request_bulk_action('bulk_actions_form', 'bulk_actions', 'conv_ids[]');")
  end

  def bulk_delete_button
    if PluginConstants::TRASH == session[:folder]
      confirm_msg = "Permanently delete selected message(s)?"
      submit_tag('Delete', :onclick => "return request_bulk_delete('bulk_actions_form', 'delete', 'conv_ids[]', '#{confirm_msg}');")
    else
      submit_tag('Trash', :onclick => "return request_bulk_delete('bulk_actions_form', 'trash', 'conv_ids[]');")
    end
  end

  def bulk_restore_button
    submit_tag('Restore', :onclick => "return request_bulk_restore('bulk_actions_form', 'conv_ids[]');")
  end

  def per_page_options
    options = PluginConstants::PER_PAGE_OPTIONS.collect {|option| [option, option]}
    return options, @message_box.messages_per_page
  end

  def per_page_selection
    select_tag('per_page', options_for_select(*per_page_options), :onchange => "update_per_page('bulk_actions_form', 'per_page');")
  end

  def pagination_links
    nav_links = will_paginate @conversations
    pagination_html = nav_links if nav_links
    #    pagination_html += page_entries_info @conversations, :entry_name => ''
    pagination_html
  end

  def message_selection_links options = nil
    options = ['All', 'None']
    html = "Select : "
    options.each do |text|
      html += selection_link(text) + '  '
    end
    html
  end

  def selection_link text
    link_to(text, nil, :onclick => "return select_messages('#{text}', 'conv_ids[]')")
  end

  def refresh_link
    link_to('Refresh', '', :onclick => "window.location.reload();")
  end

  def sort_link(text)
    link_to(text, "messages?sort=#{text.downcase}", :title => "Sort by #{text}")
  end

  def nav_link_class(selected)
    selected ? 'msg_left_option_selected' : 'msg_left_option'
  end

  def default_folder_nav_class(folder) # folder : string/symbol
    nav_link_class(session[:folder] == @default_folders[folder.to_sym] && params[:action] == 'index' )
  end

  def custom_folder_nav_class(folder) # folder : string
    nav_link_class(session[:folder] == folder && params[:action] == 'index' )
  end

  def new_message_nav_class
    nav_link_class(params[:folder].blank? && params[:action] == 'compose')
  end

  def select_box_for_priorities
    options = MessageConversation.priorities.collect {|key , val| [val, key]}
    select_tag('message[priority]', options_for_select(options, params[:priority] ?
          params[:message][:priority] : 0) )
  end
end