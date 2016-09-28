# Shenanigans because we're not in a Rails environment and we need to load bits of
# code that depend on Rails in order to test migrating objects.
Hydra::Engine.config.autoload_paths.each { |path| $LOAD_PATH.unshift path }

# in gem version 2.4, .find_by_name isn't pulling up gems given in the Gemfile
# as opposed to those in the gemspec file.
# This is a workaround:
Gem::Specification.all.each do |g|
  HAC_DIR = g.gem_dir if g.name == "hydra-access-controls"
  HCC_DIR = g.gem_dir if g.name == "curation_concerns"
  HCR_DIR = g.gem_dir if g.name == "hydra-core"
  BKL_DIR = g.gem_dir if g.name == "blacklight"
end

# CurationConcerns relies on ActionController::Base
require 'action_controller'

# Load Rails-specific bits of blacklight
require BKL_DIR + '/app/controllers/concerns/blacklight/request_builders'
require BKL_DIR + '/app/controllers/concerns/blacklight/search_helper'

# Load Rails-specific bits of hydra-access-controls
require HAC_DIR + '/app/vocabularies/acl'
require HAC_DIR + '/app/vocabularies/hydra/acl'
require HAC_DIR + '/app/models/role_mapper'
require HAC_DIR + '/app/models/ability'
require HAC_DIR + '/app/models/hydra/access_control'
require HAC_DIR + '/app/models/hydra/access_controls/access_control_list'
require HAC_DIR + '/app/models/hydra/access_controls/permission'
require HAC_DIR + '/app/models/hydra/access_controls/embargo'
require HAC_DIR + '/app/models/hydra/access_controls/lease'
require HAC_DIR + '/app/models/concerns/hydra/with_depositor'
require HAC_DIR + '/app/services/hydra/lease_service'
require HAC_DIR + '/app/services/hydra/embargo_service'
require HAC_DIR + '/app/validators/hydra/future_date_validator'

# Loading curation_concerns
require 'curation_concerns'
require HCR_DIR + '/app/models/concerns/hydra/models'
require HCC_DIR + '/app/models/concerns/curation_concerns/basic_metadata'
require HCC_DIR + '/app/models/concerns/curation_concerns/required_metadata'
require HCC_DIR + '/app/models/concerns/curation_concerns/collection'
require HCC_DIR + '/app/services/curation_concerns/derivative_path'
require HCC_DIR + '/app/services/curation_concerns/thumbnail_path_service'
require HCC_DIR + '/app/services/curation_concerns/indexes_thumbnails'
require HCC_DIR + '/app/services/curation_concerns/noid'
require HCC_DIR + '/app/models/concerns/curation_concerns/human_readable_type'
require HCC_DIR + '/app/models/concerns/curation_concerns/has_representative'
require HCC_DIR + '/app/models/concerns/curation_concerns/permissions/readable'
require HCC_DIR + '/app/models/concerns/curation_concerns/permissions/writable'
require HCC_DIR + '/app/models/concerns/curation_concerns/permissions'
require HCC_DIR + '/app/validators/has_one_title_validator'
require HCC_DIR + '/app/models/concerns/curation_concerns/collection_behavior'
require HCC_DIR + '/app/indexers/curation_concerns/file_set_indexer'
require HCC_DIR + '/app/indexers/curation_concerns/collection_indexer'

module ExampleModel
  class RDFProperties < ActiveFedora::Base
    property :title, predicate: ::RDF::Vocab::DC.title do |index|
      index.as :stored_searchable, :facetable
    end
    property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
      index.as :stored_searchable, :facetable
    end
    property :description, predicate: ::RDF::Vocab::DC.description do |index|
      index.type :text
      index.as :stored_searchable
    end
  end

  class VersionedDatastream < ActiveFedora::File
    self.versionable = true
  end

  class VersionedContent < ActiveFedora::Base
    has_subresource "content", class_name: "ExampleModel::VersionedDatastream"
  end

  class MigrationObject < ActiveFedora::Base
    include Hydra::AccessControls::Permissions
    has_subresource "content", class_name: "ExampleModel::VersionedDatastream"
    has_subresource "thumbnail", class_name: "ActiveFedora::File"
    has_subresource "characterization", class_name: "ActiveFedora::File"
  end

  class OmDatastreamExample < ActiveFedora::Base
    has_subresource "characterization", class_name: "ActiveFedora::OmDatastream"
  end

  class RDFObject < ActiveFedora::Base
    property :title, predicate: ::RDF::Vocab::DC.title do |index|
      index.as :stored_searchable, :facetable
    end

    property :description, predicate: ::RDF::Vocab::DC.description

    property :date_uploaded, predicate: ::RDF::Vocab::DC.dateSubmitted, multiple: false do |index|
      index.type :date
      index.as :stored_sortable
    end

    property :date_modified, predicate: ::RDF::Vocab::DC.modified, multiple: false do |index|
      index.type :date
      index.as :stored_sortable
    end

    has_subresource "content", class_name: "ExampleModel::VersionedDatastream"
    has_subresource "thumbnail", class_name: "ActiveFedora::File"
    has_subresource "characterization", class_name: "ActiveFedora::File"
  end

  class Collection < ActiveFedora::Base
    include CurationConcerns::CollectionBehavior
    include CurationConcerns::BasicMetadata

    # we're not messing with validators here
    clear_validators!
    has_and_belongs_to_many :members, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasCollectionMember, class_name: "ActiveFedora::Base", after_remove: :remove_member

    def remove_member(_m)
    end

    # Overriding the below to allow GenericFile for tests
    # Compute the sum of each file in the collection using Solr to
    # avoid having to access Fedora
    #
    # @return [Fixnum] size of collection in bytes
    # @raise [RuntimeError] unsaved record does not exist in solr
    def bytes
      return 0 if member_ids.count == 0

      raise "Collection must be saved to query for bytes" if new_record?

      # One query per member_id because Solr is not a relational database
      sizes = member_ids.collect do |work_id|
        query = ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: ::GenericFile.to_class_uri)
        argz = { fl: "id, #{file_size_field}",
                 fq: "{!join from=#{member_ids_field} to=id}id:#{work_id}"
        }
        files = ActiveFedora::SolrService.query(query, argz)
        files.reduce(0) { |sum, f| sum + f[file_size_field].to_i }
      end

      sizes.reduce(0, :+)
    end
  end

  class GenericFile < MigrationObject
    belongs_to :batch, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf
    property :title, predicate: ::RDF::Vocab::DC.title do |index|
      index.as :stored_searchable, :facetable
    end
    property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
      index.as :stored_searchable, :facetable
    end
  end
end
