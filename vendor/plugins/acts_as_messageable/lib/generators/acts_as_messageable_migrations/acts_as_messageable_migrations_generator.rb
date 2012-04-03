class ActsAsMessageableMigrationsGenerator < Rails::Generators::Base
  #source_root File.expand_path('../templates', __FILE__)
  include Rails::Generators::Migration

  def self.source_root
    @source_root ||= File.expand_path('../templates', __FILE__)
  end

  def create_migration
    unless options[:skip_migrations]
      migration_template 'create_message_boxes.rb', 'db/migrate/create_message_boxes.rb'
      sleep 1
      migration_template 'create_messages.rb', 'db/migrate/create_messages.rb'
      sleep 1
      migration_template 'create_message_recipients.rb', 'db/migrate/create_message_recipients.rb'
      sleep 1
      migration_template 'create_message_conversations.rb', 'db/migrate/create_message_conversations.rb'
      sleep 1
      migration_template 'create_message_folders.rb', 'db/migrate/create_message_folders.rb'
      sleep 1
      migration_template 'create_message_templates.rb', 'db/migrate/create_message_templates.rb'
      sleep 1
      migration_template 'create_template_categories.rb', 'db/migrate/create_template_categories.rb'
      sleep 1
      migration_template 'create_quick_messages.rb', 'db/migrate/create_quick_messages.rb'
      sleep 1
      migration_template 'create_default_templates.rb', 'db/migrate/create_default_templates.rb'
    end
  end

  def self.next_migration_number(dirname) #:nodoc:
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  protected

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-migrations",
      "Don't generate migration files") { |v| options[:skip_migrations] = v }
  end
end
