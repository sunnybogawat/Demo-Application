module CommonMethods
  def setup_message_box
    if params[:user_id].to_i == current_user.id.to_i or controller_name == 'default_templates'
      @message_box = current_user.message_box
      @new_messages_count = @message_box.new_conversations.length
      @drafts_count = @message_box.draft_conversations.length
      @trash_count = @message_box.trashed_conversations.length
      @default_folders = DefaultFolder.name_hash.merge(:trash => PluginConstants::TRASH) # hash
      @folders = @message_box.custom_folder_names # array
      session[:folder] = params[:folder] || session[:folder] || @default_folders[:inbox]
      session[:sort] ||= {}
      set_sort_parameters
      
    else
      render :text => "You are not permitted to view this page!" and return
    end
  end

  def render_bad_request
    render :text => "BAD REQUEST!"
  end

  def check_configurations
    @configurations = YAML::load(File.open("#{Rails.root.to_s}/config/configurations.yml"))
    if controller_name == "default_templates" and @configurations['messages']['default_templates'] == 0
      render :text => "You are not permitted to view this page!" and return
    end
    if controller_name == "custom_templates" and @configurations['messages']['custom_templates'] == 0
      render :text => "You are not permitted to view this page!" and return
    end
    if controller_name == "custom_folders" and  @configurations['messages']['custom_folders'] == 0
      render :text => "You are not permitted to view this page!" and return
    end
  end
  
  def set_sort_parameters
    sort_by = params[:sort].nil? ? nil : PluginConstants::SORT[:by][params[:sort].to_sym]
    # a nil value of sort_by at this stage means sort links have not been clicked
    # so the sorting parameters shud remain as they were

    # the foll if condition will change the parameters only when a valid sort link is clicked
    if session[:sort][:by] == sort_by
      # If the same sort link is clicked consecutively the sort order will change
      change_sort_order
    elsif !sort_by.nil?
      # if a sort link has been clicked but is diff from the previously clicked sort link
      session[:sort][:order] = PluginConstants::SORT[:order][:desc]
    end

    session[:sort][:by] = sort_by || session[:sort][:by] || PluginConstants::SORT[:by][:received]
  end

  def change_sort_order
    if session[:sort][:order] == PluginConstants::SORT[:order][:desc]
      session[:sort][:order] = PluginConstants::SORT[:order][:asc]
    else
      session[:sort][:order] = PluginConstants::SORT[:order][:desc]
    end
  end  
end