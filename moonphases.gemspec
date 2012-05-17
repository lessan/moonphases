Gem::Specification.new do |s|
  s.name        = 'moonphases'
  s.version     = '1.0.3'
  s.summary     = "MoonPhases-#{s.version}"
  s.description = "Recovers the phase of the moon for various historical dates."
  s.authors     = ["Curtis Lacy"]
  s.email       = 'curtis.lacy@grgcomponents.com'
  s.files       = Dir["{app,lib,config,test}/**/*","Rakefile","Gemfile","MIT-LICENSE","README.md"]
  s.add_runtime_dependency "nokogiri"
end
