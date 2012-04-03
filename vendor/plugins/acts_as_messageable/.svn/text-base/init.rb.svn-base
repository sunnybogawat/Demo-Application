%w{ models controllers helpers views }.each do |dir|
  path = File.expand_path(File.join(File.dirname(__FILE__), 'app', dir))
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end
path = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
ActiveSupport::Dependencies.autoload_paths << path
ActiveSupport::Dependencies.autoload_once_paths.delete(path)

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Messageable)
