require 'spec_helper'

describe "Collections with missing files" do

  let(:collection)    { "x346dj04v" }
  let(:files)         { ["x346dj06d", "x346dj08z"] }
  let(:missing_file)  { "x346dj07p" }

  before do
    FedoraMigrate::ObjectMover.new(FedoraMigrate.find("scholarsphere:"+collection), ExampleModel::Collection.new(collection)).migrate
    files.each { |f| FedoraMigrate::ObjectMover.new(FedoraMigrate.find("scholarsphere:"+f), ExampleModel::MigrationObject.new(f)).migrate }
  end

  context "when migrating relationships" do

    before do
      allow(FedoraMigrate::Logger).to receive(:warn)
      FedoraMigrate::RelsExtDatastreamMover.new(FedoraMigrate.find("scholarsphere:"+collection)).migrate
    end

    let(:migrated_collection) { ExampleModel::Collection.all.first }

    it "should only migrate existing relationships" do
      expect(migrated_collection.members.count).to eql 2
      expect(migrated_collection.member_ids).to_not include(missing_file)
    end

  end

end
