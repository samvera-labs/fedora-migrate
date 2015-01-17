require 'spec_helper'

describe "Migrating an object" do

  let(:source)    { FedoraMigrate.source.connection.find("sufia:rb68xc089") }
  let(:fits_xml)  { load_fixture("sufia-rb68xc089-characterization.xml").read }

  context "when the target model is provided" do

    let(:mover) { FedoraMigrate::ObjectMover.new source, ExampleModel::MigrationObject.new }
    
    subject do
      mover.migrate
      mover.target
    end

    it "should migrate the entire object" do
      expect(subject.content.versions.all.count).to eql 3
      expect(subject.thumbnail.mime_type).to eql "image/jpeg"
      expect(subject.thumbnail.versions.all.count).to eql 0
      expect(subject.characterization.content).to be_equivalent_to(fits_xml)
      expect(subject.characterization.versions.all.count).to eql 0
      expect(subject).to be_kind_of ExampleModel::MigrationObject
    end

    it "should migrate the object's permissions" do
      expect(subject.edit_users).to include("jilluser@example.com")
    end

  end

  context "when we have to determine the model" do

    let(:mover) { FedoraMigrate::ObjectMover.new source }

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

      it "should migrate the entire object" do
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
      it "should fail" do
        expect{mover.migrate}.to raise_error(FedoraMigrate::Errors::MigrationError)
      end
    end

  end

  context "when the object has an ntriples datastream" do

    context "and we want to convert it to a provided model" do
      let(:mover) { FedoraMigrate::ObjectMover.new(source, ExampleModel::RDFObject.new, {convert: "descMetadata"}) }
    
      subject do
        mover.migrate
        mover.target
      end

      it "should migrate the entire object" do
        expect(subject.content.versions.all.count).to eql 3
        expect(subject.thumbnail.mime_type).to eql "image/jpeg"
        expect(subject.thumbnail.versions.all.count).to eql 0
        expect(subject.characterization.content).to be_equivalent_to(fits_xml)
        expect(subject.characterization.versions.all.count).to eql 0
        expect(subject).to be_kind_of ExampleModel::RDFObject
        expect(subject.title).to eql(["world.png"])
      end

    end

    context "and we want to convert multiple datastreas" do

      # Need a fixture with two different datastreams for this test to be more effective      
      let(:mover) { FedoraMigrate::ObjectMover.new(source, ExampleModel::RDFObject.new, {convert: ["descMetadata", "descMetadata"]}) }
    
      subject do
        mover.migrate
        mover.target
      end

      it "should migrate all the datastreams" do
        expect(subject.title).to eql(["world.png"])
      end
    end

    context "with RDF errors" do
      let(:problem_source) { FedoraMigrate.source.connection.find("scholarsphere:sf2686078") }
      let(:mover) { FedoraMigrate::ObjectMover.new(problem_source, ExampleModel::RDFObject.new, {convert: "descMetadata"}) }
      subject do
        mover.migrate
        mover.target
      end

      it "should migrate the content" do
        expect(subject.title).to eql([" The \"Value Added\" in Editorial Acquisitions.pdf"])
      end
    end

  end

end
