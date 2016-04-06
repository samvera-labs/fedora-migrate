require 'spec_helper'

describe FedoraMigrate::ObjectMover do
  let(:source)    { FedoraMigrate.source.connection.find("sufia:rb68xc089") }
  let(:fits_xml)  { load_fixture("sufia-rb68xc089-characterization.xml").read }

  context "when the target model is provided" do
    let(:mover) { described_class.new source, ExampleModel::MigrationObject.new }

    subject do
      mover.migrate
      mover.target
    end

    it "migrates the entire object" do
      expect(subject.content.versions.all.count).to eql 3
      expect(subject.thumbnail.mime_type).to eql "image/jpeg"
      expect(subject.thumbnail.versions.all.count).to eql 0
      expect(subject.characterization.content).to be_equivalent_to(fits_xml)
      expect(subject.characterization.versions.all.count).to eql 0
      expect(subject).to be_kind_of ExampleModel::MigrationObject
    end

    it "migrates the object's permissions" do
      expect(subject.edit_users).to include("jilluser@example.com")
    end

    describe "objects with Om datastreams" do
      let(:mover) { described_class.new(source, ExampleModel::OmDatastreamExample.new) }
      subject do
        mover.migrate
        mover.target
      end
      it "migrates the object without warnings" do
        expect(FedoraMigrate::Logger).not_to receive(:warn)
        expect(subject.characterization.ng_xml).to be_equivalent_to(fits_xml)
      end
    end
  end

  context "when we have to determine the model" do
    let(:mover) { described_class.new source }

    context "and it is defined" do
      before do
        Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
        class GenericFile < ActiveFedora::Base
          contains "content", class_name: "ExampleModel::VersionedDatastream"
          contains "thumbnail", class_name: "ActiveFedora::Datastream"
          contains "characterization", class_name: "ActiveFedora::Datastream"
        end
      end

      subject do
        mover.migrate
        mover.target
      end

      it "migrates the entire object" do
        expect(subject.content.versions.all.count).to eql 3
        expect(subject.thumbnail.mime_type).to eql "image/jpeg"
        expect(subject.thumbnail.versions.all.count).to eql 0
        expect(subject.characterization.content).to be_equivalent_to(fits_xml)
        expect(subject.characterization.versions.all.count).to eql 0
        expect(subject).to be_kind_of GenericFile
      end
    end

    context "and it is not defined" do
      before do
        Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      end
      it "fails" do
        expect { mover.migrate }.to raise_error(FedoraMigrate::Errors::MigrationError)
      end
    end
  end

  context "when the object has an ntriples datastream" do
    context "and we want to convert it to a provided model" do
      let(:mover) { described_class.new(source, ExampleModel::RDFObject.new, convert: "descMetadata") }

      subject do
        mover.migrate
        mover.target
      end

      it "migrates the entire object" do
        expect(subject.content.versions.all.count).to eql 3
        expect(subject.thumbnail.mime_type).to eql "image/jpeg"
        expect(subject.thumbnail.versions.all.count).to eql 0
        expect(subject.characterization.content).to be_equivalent_to(fits_xml)
        expect(subject.characterization.versions.all.count).to eql 0
        expect(subject).to be_kind_of ExampleModel::RDFObject
        expect(subject.title).to eql(["world.png"])
      end

      it "migrates the createdDate and lastModifiedDate" do
        # The value of lastModifiedDate will depend on when you loaded your test fixtures
        expect(subject.date_modified).to eq source.lastModifiedDate
        expect(subject.date_uploaded).to eq '2014-10-15T03:50:37.063Z'
      end
    end

    context "with ISO-8859-1 characters" do
      let(:problem_source) { FedoraMigrate.source.connection.find("scholarsphere:5712mc568") }
      let(:mover) { described_class.new(problem_source, ExampleModel::RDFObject.new, convert: "descMetadata") }
      subject do
        mover.migrate
        mover.target
      end

      it "migrates the content" do
        expect(subject.description.first).to match(/^The relationship between school administrators and music teachers/)
      end
    end

    context "and we want to convert multiple datastreas" do
      # Need a fixture with two different datastreams for this test to be more effective
      let(:mover) { described_class.new(source, ExampleModel::RDFObject.new, convert: ["descMetadata", "descMetadata"]) }

      subject do
        mover.migrate
        mover.target
      end

      it "migrates all the datastreams" do
        expect(subject.title).to eql(["world.png"])
      end
    end

    context "with RDF errors" do
      let(:problem_source) { FedoraMigrate.source.connection.find("scholarsphere:sf2686078") }
      let(:mover) { described_class.new(problem_source, ExampleModel::RDFObject.new, convert: "descMetadata") }
      subject do
        mover.migrate
        mover.target
      end

      it "migrates the content" do
        expect(subject.title).to eql([" The \"Value Added\" in Editorial Acquisitions.pdf"])
      end
    end
  end
end
