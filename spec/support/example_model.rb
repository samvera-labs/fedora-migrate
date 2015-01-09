# Shenanigans because we're not in a Rails environment and we need Hydra::AccessControls
Hydra::Engine.config.autoload_paths.each { |path| $LOAD_PATH.unshift path }
# in gem version 2.4, .find_by_name isn't pulling up gems given in the Gemfile
# as opposed to those in the gemspec file.
# This is a workaround:
Gem::Specification.all.each do |g|
  HAC_DIR = g.gem_dir if g.name.match("hydra-access-controls")
end
require HAC_DIR+'/app/vocabularies/acl'
require HAC_DIR+'/app/vocabularies/hydra/acl'
require HAC_DIR+'/app/models/role_mapper'
require HAC_DIR+'/app/models/ability'
require HAC_DIR+'/app/models/hydra/access_controls/access_control_list'
require HAC_DIR+'/app/models/hydra/access_controls/permission'
require HAC_DIR+'/app/models/hydra/access_controls/embargo'
require HAC_DIR+'/app/models/hydra/access_controls/lease'
require HAC_DIR+'/app/services/hydra/lease_service'
require HAC_DIR+'/app/services/hydra/embargo_service'
require HAC_DIR+'/app/validators/hydra/future_date_validator'

module ExampleModel

  class RDFProperties < ActiveFedora::Base
    property :title, predicate: ::RDF::DC.title do |index|
      index.as :stored_searchable, :facetable
    end
    property :creator, predicate: ::RDF::DC.creator do |index|
      index.as :stored_searchable, :facetable
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

  class RDFObject < ActiveFedora::Base
    property :title, predicate: ::RDF::DC.title do |index|
      index.as :stored_searchable, :facetable
    end
    contains "content", class_name: "ExampleModel::VersionedDatastream"
    contains "thumbnail", class_name: "ActiveFedora::File"
    contains "characterization", class_name: "ActiveFedora::File"
  end

end
