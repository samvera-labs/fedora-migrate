# Shenanigans because we're not in a Rails environment and we need to load bits of 
# code that depend on Rails in order to test migrating objects.
Hydra::Engine.config.autoload_paths.each { |path| $LOAD_PATH.unshift path }
# in gem version 2.4, .find_by_name isn't pulling up gems given in the Gemfile
# as opposed to those in the gemspec file.
# This is a workaround:
Gem::Specification.all.each do |g|
  HAC_DIR = g.gem_dir if g.name.match("hydra-access-controls")
  HCL_DIR = g.gem_dir if g.name.match("hydra-collections")
  HCR_DIR = g.gem_dir if g.name.match("hydra-core")
end

# Load Rails-specific bits of hydra-access-controls
require HAC_DIR+'/app/vocabularies/acl'
require HAC_DIR+'/app/vocabularies/hydra/acl'
require HAC_DIR+'/app/models/role_mapper'
require HAC_DIR+'/app/models/ability'
require HAC_DIR+'/app/models/hydra/access_controls/access_control_list'
require HAC_DIR+'/app/models/hydra/access_controls/permission'
require HAC_DIR+'/app/models/hydra/access_controls/embargo'
require HAC_DIR+'/app/models/hydra/access_controls/lease'
require HAC_DIR+'/app/models/concerns/hydra/with_depositor'
require HAC_DIR+'/app/services/hydra/lease_service'
require HAC_DIR+'/app/services/hydra/embargo_service'
require HAC_DIR+'/app/validators/hydra/future_date_validator'

# Loading hydra-collections
require 'hydra-collections'
require HCR_DIR+'/app/models/concerns/hydra/model_methods'
require HCL_DIR+'/app/models/concerns/hydra/collection'

module ExampleModel

  class RDFProperties < ActiveFedora::Base
    property :title, predicate: ::RDF::DC.title do |index|
      index.as :stored_searchable, :facetable
    end
    property :creator, predicate: ::RDF::DC.creator do |index|
      index.as :stored_searchable, :facetable
    end
    property :description, predicate: ::RDF::DC.description do |index|
      index.type :text
      index.as :stored_searchable
    end
  end

  class VersionedDatastream < ActiveFedora::File
    has_many_versions
  end

  class VersionedContent < ActiveFedora::Base
    contains "content", class_name: "ExampleModel::VersionedDatastream"
  end

  class MigrationObject < ActiveFedora::Base
    include Hydra::AccessControls::Permissions
    contains "content", class_name: "ExampleModel::VersionedDatastream"
    contains "thumbnail", class_name: "ActiveFedora::File"
    contains "characterization", class_name: "ActiveFedora::File"
  end

  class OmDatastreamExample < ActiveFedora::Base
    contains "characterization", class_name: "ActiveFedora::OmDatastream"
  end

  class RDFObject < ActiveFedora::Base
    property :title, predicate: ::RDF::DC.title do |index|
      index.as :stored_searchable, :facetable
    end

    property :description, predicate: ::RDF::DC.description

    property :date_uploaded, predicate: ::RDF::DC.dateSubmitted, multiple: false do |index|
      index.type :date
      index.as :stored_sortable
    end

    property :date_modified, predicate: ::RDF::DC.modified, multiple: false do |index|
      index.type :date
      index.as :stored_sortable
    end

    contains "content", class_name: "ExampleModel::VersionedDatastream"
    contains "thumbnail", class_name: "ActiveFedora::File"
    contains "characterization", class_name: "ActiveFedora::File"
  end

  class Collection < ActiveFedora::Base
    include Hydra::Collection
  end

end
