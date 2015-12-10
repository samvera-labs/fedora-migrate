require 'fedora-migrate'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'jettywrapper'
require 'rubocop/rake_task'

Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/migrate.zip"

RSpec::Core::RakeTask.new(:spec)

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

desc "Run continuous integration tests"
task ci: [:rubocop, 'jetty:clean'] do
  jetty_params = Jettywrapper.load_config
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['fixtures:load'].invoke
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end
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
