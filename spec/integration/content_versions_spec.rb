require 'spec_helper'

describe "Versioned content" do

  class FileContentDatastream < ActiveFedora::Datastream
    has_many_versions
  end

  class MigrationModel < ActiveFedora::Base
    has_file_datastream "content", type: FileContentDatastream
  end

  let(:mover) do
    source = FedoraMigrate.find("sufia:rb68xc089").datastreams["content"]
    obj = MigrationModel.new(pid: source.pid.split(/:/).last)
    obj.save
    target = obj.datastreams["content"]
    FedoraMigrate::DatastreamMover.new( source: source, target: target)
  end

  context "with migrating versions" do
    subject do
      mover.versionable = true
      mover.migrate
      return mover.target
    end
    it "should migrate all versions" do
      expect(subject.versions.count).to eql 4
    end
    it "should preserve metadata" do
      expect(subject.mime_type).to eql "image/png"
      expect(subject.original_name).to eql "world.png"
    end
  end

  context "without migrating versions" do
    subject do
      mover.migrate
      return mover.target
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
