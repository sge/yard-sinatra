Gem::Specification.new do |s|
  # Get the facts.
  s.name             = "yard-sinatra"
  s.version          = "1.0.1"
  s.description      = "Displays Sinatra routes (including comments) in YARD output."

  # External dependencies
  s.add_dependency "yard", "~> 0.7"
  s.add_development_dependency "rspec", "~> 2.6"

  # Those should be about the same in any BigBand extension.
  s.authors          = ["Konstantin Haase","neglectedvalue","Oliver Weyhmueller"]
  s.email            = "oliver@weyhmueller.de"
  s.files            = Dir["**/*.{rb,md,erb,js}"] << "LICENSE"
  s.homepage         = "http://github.com/weyhmueller/#{s.name}"
  s.require_paths    = ["lib"]
  s.summary          = s.description
end
