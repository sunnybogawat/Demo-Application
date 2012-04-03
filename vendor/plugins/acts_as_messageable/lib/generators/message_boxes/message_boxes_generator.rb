class MessageBoxesGenerator < Rails::Generators::Base
  #source_root File.expand_path('../templates', __FILE__)
  include Rails::Generators::Migration

  argument :models, :type => :array, :default => []

  def self.source_root
    @source_root ||= File.expand_path('../templates', __FILE__)
  end

  #@@source_path = source_root

  def copy_config_files
    models.each do |model_name|
      klass = model_name.constantize
      users = klass.all
      users.each do |user|
        mb_user = MessageBox.new
        mb_user.messageable = user
        mb_user.save
      end
      add_plugin_name(model_name)
    end

    # copy stylesheets, images and javascripts
    unless options[:skip_css_js]
      Dir.chdir(File.join(File.dirname(__FILE__), 'templates')) do
        %w(stylesheets javascripts images).each  do |area|
          Dir.glob(File.join(area, '**','*')).each do |file1|
            template(file1, File.join(Rails.root,'public',file1))
          end
        end
      end
    end

    # Add routes in routes.rb
    file_path = "#{RAILS_ROOT}/config/routes.rb"
    content = File.read(file_path).gsub(/::Application.routes.draw do/,
      " ::Application.routes.draw do
            resources :users do
            resources :messages, :except => [:new] do
            collection do
                get :compose
                delete :empty_trash, :trash
                put :restore ,:mark , :move, :update_per_page
            end

            member do
              put :restore, :mark , :move
              delete :trash
            end
          end
      end
      match 'users/:user_id/messages/:id/send' => 'messages#post', :as => 'new_message', :defaults => {:id => 'new'}#"
    )
    File.open(file_path, 'wb') { |file| file.write(content) }
  end

  protected

  def add_plugin_name(klass)
    class_def = "class #{klass} < ActiveRecord::Base"
    gsub_file "app/models/#{klass.downcase}.rb", /(#{Regexp.escape(class_def)})/mi do |match|
      "#{match}\n acts_as_messageable\n"
    end
  end

  def gsub_file(relative_destination, regexp, *args, &block)
    path = File.expand_path(relative_destination, destination_root)
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-css-js",
      "Don't generate css and js files") { |v| options[:skip_css_js] = v }
  end
end
