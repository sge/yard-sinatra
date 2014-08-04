YARD::Templates::Engine.register_template_path(File.join(File.dirname(__FILE__), '../templates'))

require File.join(File.dirname(__FILE__), 'yard/sinatra')
require File.join(File.dirname(__FILE__), 'yard/yard-sinatra/tags')

sinatra_root = File.join(File.dirname(__FILE__), '../../../..')
$LOAD_PATH << sinatra_root unless $LOAD_PATH.include? sinatra_root

require 'config/boot'

require File.join(File.dirname(__FILE__), 'yard/crud_mounter')