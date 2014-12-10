require 'spec_helper'

describe "Versioned content" do

  let(:mover) do
    FedoraMigrate::DatastreamMover.new(
      FedoraMigrate.source.connection.find("sufia:rb68xc089").datastreams["content"], 
      ExampleModel::VersionedContent.create.attached_files["content"]
    )
  end

  context "with migrating versions" do
    subject do
      mover.migrate
      mover.target
    end
    it "should migrate all versions" do
      expect(subject.versions.all.count).to eql 3
    end
    it "should preserve metadata" do
      expect(subject.mime_type).to eql "image/png"
      expect(subject.original_name).to eql "world.png"
    end
  end

  context "without migrating versions" do
    subject do
      mover.versionable = false
      mover.migrate
      mover.target
    end
    it "should migrate only the most recent version" do
      expect(subject.versions.count).to eql 0
      expect(subject.content).to_not be_nil
    end
    it "should preserve metadata" do
      expect(subject.mime_type).to eql "image/png"
      expect(subject.original_name).to eql "world.png"
    end
  end

end
