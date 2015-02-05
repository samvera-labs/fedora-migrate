require 'spec_helper'

describe "Collections with missing files" do

  let(:collection)    { "x346dj04v" }
  let(:files)         { ["x346dj06d", "x346dj08z"] }
  let(:missing_file)  { "x346dj07p" }

  before do
    FedoraMigrate::ObjectMover.new(FedoraMigrate.find("scholarsphere:#{collection}"), ExampleModel::Collection.new(collection)).migrate
    files.each { |f| FedoraMigrate::ObjectMover.new(FedoraMigrate.find("scholarsphere:#{f}"), ExampleModel::MigrationObject.new(f)).migrate }
  end

  context "when migrating relationships" do

    let(:migrated_collection) { ExampleModel::Collection.first }
    let(:error_message) do
      "scholarsphere:#{collection} could not migrate relationship info:fedora/fedora-system:def/relations-external#hasCollectionMember because info:fedora/scholarsphere:#{missing_file} doesn't exist in Fedora 4"
    end 

    it "should only migrate existing relationships and log failed ones" do
      expect(FedoraMigrate::Logger).to receive(:warn).with(error_message)
      FedoraMigrate::RelsExtDatastreamMover.new(FedoraMigrate.find("scholarsphere:#{collection}")).migrate
      expect(migrated_collection.members.count).to eql 2
      expect(migrated_collection.member_ids).to_not include(missing_file)
    end

  end

end
