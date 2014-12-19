require 'fedora-migrate'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'jettywrapper'
Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/fedora-4/migrate.zip"

RSpec::Core::RakeTask.new(:spec)

desc "Run continuous integration tests"
task ci: ['jetty:clean', 'jetty:start', 'fixtures:load', 'spec']

namespace :fixtures do

  desc "Load Fedora3 fixtures for testing; use FIXTURE_PATH= for your own"
  task :load do
    repo = FedoraMigrate.source
    path = ENV["FIXTURE_PATH"] || "spec/fixtures/objects" 
    Dir.glob(File.join(path,"*.xml")).each do |f|
      fixture = File.open(f)
      begin
        repo.connection.ingest(file: fixture.read)
      rescue
        puts "Failed to load #{fixture.path} (skipping)"
      end
    end
  end

  desc "Remove all objects from Fedora3"
  task :unload do
    repo = FedoraMigrate.source
    repo.connection.search("").collect { |o| o.delete }
  end

  desc "Reload fixtures into Fedora3"
  task reload: [:unload, :load]

end
