$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api_transcript_agent/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api_transcript_agent"
  s.version     = ApiTranscriptAgent::VERSION
  s.authors     = ["Joachim Garth"]
  s.email       = ["jg@viaeurope.com"]
  s.homepage    = "https://github.com/jgarth/api_transcript_agent"
  s.summary     = "The agent gem for API Transcript"
  s.description = "The agent gem for API Transcript"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "net-http-persistent", "~> 2.5", ">= 2.5.2"
  s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "webmock"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "pry-nav"
end
