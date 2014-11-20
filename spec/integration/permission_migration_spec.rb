require 'spec_helper'

describe "Migrating permisisons" do

  let(:source) { FedoraMigrate.source.connection.find("sufia:rb68xc089") }
 
  subject { FedoraMigrate::PermissionsMover.new(source.datastreams["rightsMetadata"], ExampleModel::MigrationObject.new)}

  it "should display the permissions from the source datastream" do
    expect(subject.edit_users).to include("jilluser@example.com")
  end

end
