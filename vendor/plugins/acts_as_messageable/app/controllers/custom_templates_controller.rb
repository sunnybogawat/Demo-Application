class CustomTemplatesController < ApplicationController
  require 'common_methods.rb'
  include CommonMethods
  layout "messages"
   uses_tiny_mce
  helper :messages
  before_filter :user_login_required, :setup_message_box ,:check_configurations

  def index
    list
    respond_to do |format|
      format.html { render :action => 'list'}
      format.js
    end
  end

  def list
    @custom_templates = CustomTemplate.paginate(:per_page => 5, :page => params[:page])
  end

  def show
    custom_template = CustomTemplate.find(params[:id])
    @message = @message_box.compose_message(:subject => custom_template.subject,:body => custom_template.body)
    @users = User.possible_recipients_for_message(@message)
    respond_to do |format|
      format.html
    end
  end

  def new
    @custom_tamplate = CustomTemplate.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @custom_tamplate = CustomTemplate.new(params[:custom_template])
    @custom_tamplate.author_id = current_user

    if @custom_tamplate.save
      flash[:notice] = 'Custom template successfully created.'
      respond_to do |format|
        format.html {redirect_to :action => 'list'}
      end
    else
      respond_to do |format|
        format.html {render :action => 'new'}
      end
    end
  end

  def edit
    @custom_template = CustomTemplate.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @custom_template = CustomTemplate.find(params[:id])
    respond_to do |format|
      if @custom_template.update_attributes(params[:custom_template])
        flash[:notice] = 'Custom template successfully updated.'
        format.html {redirect_to :action => 'show', :id => @custom_template}
      else
        format.html {render :action => 'edit'}
      end
    end
  end

  def destroy
    CustomTemplate.find(params[:id]).destroy
    respond_to do |format|
      format.html {redirect_to :action => 'list'}
    end
  end
  
end