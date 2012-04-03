class DefaultTemplatesController < ApplicationController
  require 'common_methods.rb'
  include CommonMethods
  layout 'messages'
  helper :messages
  uses_tiny_mce
  before_filter :user_login_required, :setup_message_box ,:check_configurations

  def index
    list
    respond_to do |format|
      format.html { render :action => 'list'}
      format.js
    end
  end

  def list
    @default_tamplates = DefaultTemplate.paginate(:per_page => 5, :page => params[:page])
  end

  def show
    @default_tamplate = DefaultTemplate.find(params[:id])
    @message = @message_box.compose_message(:subject => @default_tamplate.title,:body => @default_tamplate.message)
    @users = User.possible_recipients_for_message(@message)
    respond_to do |format|
      format.html
    end
  end

  def new
    @default_tamplate = DefaultTemplate.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @default_tamplate = DefaultTemplate.new(params[:default_template])
    
    if @default_tamplate.save
      flash[:notice] = 'Default template successfully created.'
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
    @default_tamplate = DefaultTemplate.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @default_tamplate = DefaultTemplate.find(params[:id])
    respond_to do |format|
      if @default_tamplate.update_attributes(params[:default_template])
        flash[:notice] = 'Default template successfully updated.'
        format.html {redirect_to :action => 'show', :id => @default_tamplate}
      else
        format.html {render :action => 'edit'}
      end
    end
  end

  def destroy
    DefaultTemplate.find(params[:id]).destroy
    respond_to do |format|
      format.html {redirect_to :action => 'list'}
    end
  end
  
end