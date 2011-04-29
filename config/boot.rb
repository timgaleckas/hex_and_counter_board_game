require "rubygems"
require "bundler"

Bundler.require(:default)

require 'active_support/inflector'

AUTOLOAD_PATHS = ['lib']

AUTOLOAD_PATHS.each do |path|
  Dir.glob(path+'/**/*.rb').each do |ruby_file|
    require_line = ruby_file.sub(/\.rb$/,'')
    class_name_sym = File.basename(require_line).classify.to_sym
    autoload class_name_sym, require_line
  end
end

Dir.glob('initializers/*.rb').each do |ruby_file|
  require ruby_file
end
