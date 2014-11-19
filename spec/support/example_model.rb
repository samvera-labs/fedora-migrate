module ExampleModel

  class RDFProperties < ActiveFedora::Base
    property :title, predicate: ::RDF::DC.title do |index|
      index.as :stored_searchable, :facetable
    end
    property :creator, predicate: ::RDF::DC.creator do |index|
      index.as :stored_searchable, :facetable
    end
  end

  class VersionedDatastream < ActiveFedora::Datastream
    has_many_versions
  end

  class VersionedContent < ActiveFedora::Base
    has_file_datastream "content", type: VersionedDatastream
  end

  class MigrationObject < ActiveFedora::Base
    has_file_datastream "content", type: VersionedDatastream
    has_file_datastream "thumbnail", type: ActiveFedora::Datastream
    has_file_datastream "characterization", type: ActiveFedora::Datastream
  end

  class RDFObject < ActiveFedora::Base
    property :title, predicate: ::RDF::DC.title do |index|
      index.as :stored_searchable, :facetable
    end
    has_file_datastream "content", type: VersionedDatastream
    has_file_datastream "thumbnail", type: ActiveFedora::Datastream
    has_file_datastream "characterization", type: ActiveFedora::Datastream
  end

end
