$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "codelation_pages/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "codelation_pages"
  s.version     = CodelationPages::VERSION
  s.authors     = ["Brian Pattison"]
  s.email       = ["brian@brianpattison.com"]
  s.homepage    = "https://github.com/codelation/codelation_pages"
  s.summary     = "A extension of Rails routes mapper for automatically registering static pages."
  s.description = "Codelation Pages automatically registers static pages in `app/views/pages` with dasherized routes and automatically generated controllers for pages in subfolders."
  s.licenses    = ["MIT"]

  s.files = Dir["{app,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.0"
  s.add_development_dependency "rake"
end
