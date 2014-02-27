$:.push File.expand_path("../lib", __FILE__)
require File.join(File.dirname(__FILE__), 'lib', 'yard', 'yard-sinatra', 'version.rb')

Gem::Specification.new do |s|
  # Get the facts.
  s.name             = "yard-sinatra"
  s.version          = "#{YARD::Sinatra::VERSION}.sge"
  s.description      = "Generate documentation for your Sinatra-based API like a boss!"

  # External dependencies
  s.add_dependency "yard", "~> 0.7"
  s.add_dependency "activesupport"
  s.add_development_dependency "rspec", "~> 2.6"

  # Those should be about the same in any BigBand extension.
  s.authors          = [ "Chris Bielinski", "Konstantin Haase","neglectedvalue","Oliver Weyhmueller"]
  s.email            = "chris@sleepygiant.com"
  s.files            = Dir["**/*.{rb,md,erb,js}"] << "LICENSE"
  s.homepage         = "http://github.com/sge/#{s.name}"
  s.require_paths    = [ "lib" ]
  s.summary          = s.description
end
