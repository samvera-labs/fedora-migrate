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
