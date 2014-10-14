require 'rspec/core'
require 'rspec/core/rake_task'
require 'jettywrapper'
Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/fedora-4/migrate.zip"

RSpec::Core::RakeTask.new(:spec)
