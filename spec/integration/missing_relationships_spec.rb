require 'spec_helper'

describe ExampleModel::Collection do
  let(:collection)    { "x346dj04v" }
  let(:files)         { ["x346dj06d", "x346dj08z"] }
  let(:missing_file)  { "x346dj07p" }

  before do
    FedoraMigrate::ObjectMover.new(FedoraMigrate.find("scholarsphere:#{collection}"), described_class.new(collection)).migrate
    files.each { |f| FedoraMigrate::ObjectMover.new(FedoraMigrate.find("scholarsphere:#{f}"), ExampleModel::MigrationObject.new(f)).migrate }
  end

  context "when migrating relationships" do
    let(:migrated_collection) { described_class.first }
    let(:error_message) do
      "scholarsphere:#{collection} could not migrate relationship info:fedora/fedora-system:def/relations-external#hasCollectionMember because info:fedora/scholarsphere:#{missing_file} doesn't exist in Fedora 4"
    end
    before { FedoraMigrate::RelsExtDatastreamMover.new(FedoraMigrate.find("scholarsphere:#{collection}")).migrate }
    it "only migrates existing relationships" do
      expect(migrated_collection.members.count).to eql 2
      expect(migrated_collection.member_ids).to_not include(missing_file)
    end
  end

  context "when reporting" do
    subject { FedoraMigrate::RelsExtDatastreamMover.new(FedoraMigrate.find("scholarsphere:#{collection}")).migrate }
    it "includes failed relationships" do
      expect(subject.sort.first).to match(/^could not migrate relationship/)
    end
    it "includes all the possible relationships" do
      expect(subject.count).to eql 3
    end
    it "includes the successful relationships" do
      expect(subject.sort.last).to match(/^http/)
    end
  end
end
