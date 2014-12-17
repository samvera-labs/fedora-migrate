require 'active_fedora/cleaner'

# These should work for Sufia-based applications, although you will need to modify them
# accordingly if you namespace and conversion strategies differ.

namespace :fedora do

  namespace :migrate do
    desc "Migrates all objects in a Sufia-based application"
    task sufia: :environment do
      results = FedoraMigrate.migrate_repository(namespace: "sufia", options: {convert: "descMetadata"})
      puts results
    end

    desc "Empties out the Fedora4 repository"
    task reset: :environment do
      FedoraMigrate::Logger.info "Removing all objects from the Fedora4 repository"
      ActiveFedora::Cleaner.clean!
    end
  end

end
