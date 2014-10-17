require 'spec_helper'

describe "Migrating an object" do

  class VersionedDatastream < ActiveFedora::Datastream
    has_many_versions
  end

  class MigrationModel < ActiveFedora::Base
    has_file_datastream "content", type: VersionedDatastream
    has_file_datastream "thumbnail", type: ActiveFedora::Datastream
    has_file_datastream "characterization", type: ActiveFedora::Datastream
  end

  let(:source)    { FedoraMigrate.source.connection.find("sufia:rb68xc089") }
  let(:fits_xml)  { load_fixture("sufia-rb68xc089-characterization.xml").read }

  context "when the target model is provided" do

    let(:mover) { FedoraMigrate::ObjectMover.new source, MigrationModel.new }
    
    subject do
      mover.migrate
      mover.target
    end

    it "should migrate the entire object" do
      expect(subject.content.versions.count).to eql 4
      expect(subject.thumbnail.mime_type).to eql "image/jpeg"
      expect(subject.thumbnail.versions.count).to eql 0
      expect(subject.characterization.content).to be_equivalent_to(fits_xml)
      expect(subject.characterization.versions.count).to eql 0
      expect(subject).to be_kind_of MigrationModel
    end

  end

  context "when we have to determine the model" do

    let(:mover) { FedoraMigrate::ObjectMover.new source }

    context "and it is defined" do
      subject do
        class GenericFile < MigrationModel; end
        mover.migrate
        mover.target
      end

      it "should migrate the entire object" do
        expect(subject.content.versions.count).to eql 4
        expect(subject.thumbnail.mime_type).to eql "image/jpeg"
        expect(subject.thumbnail.versions.count).to eql 0
        expect(subject.characterization.content).to be_equivalent_to(fits_xml)
        expect(subject.characterization.versions.count).to eql 0
        expect(subject).to be_kind_of GenericFile
      end
    end

    context "and it is not defined" do
      before do
        Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      end
      it "should fail" do
        expect{mover.migrate}.to raise_error(NameError)
      end
    end

  end

end
