class CustomFoldersController < ApplicationController
  require 'common_methods.rb'
  include CommonMethods
  layout "messages"
  helper :messages
  uses_tiny_mce
  before_filter :user_login_required, :setup_message_box ,:check_configurations,

    def set_sesion
    current_user = User.find(params[:user_id])
  end
  
  def index
    list
    render :action => 'list'
  end

  def list
    @custom_folders = CustomFolder.paginate(:per_page => 10,:page => params[:page], :conditions => {:user_id => params[:user_id].to_i})
  end

  def show
    @custom_folder = CustomFolder.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def new
    
    @custom_folder = CustomFolder.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @custom_folder = CustomFolder.new(params[:custom_folder])
    @custom_folder.user_id = current_user
    respond_to do |format|
      if @custom_folder.save
        flash[:notice] = 'Custom Folder successfully created.'
        format.html {redirect_to :action => 'list'}
      else
        format.html {render :action => 'new'}
      end
    end
  end

  def edit
    @custom_folder = CustomFolder.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def update
    @custom_folder = CustomFolder.find(params[:id])
    respond_to do |format|
      if @custom_folder.update_attributes(params[:custom_folder])
        flash[:notice] = 'Custom Folder successfully updated.'
        format.html {redirect_to :action => 'show', :id => @custom_folder}
      else
        format.html {render :action => 'edit'}
      end
    end
  end

  def destroy
    CustomFolder.find(params[:id]).destroy
    respond_to do |format|
      format.html {redirect_to :action => 'list'}
    end
  end
   
end