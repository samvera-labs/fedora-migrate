require 'spec_helper'

describe FedoraMigrate::PermissionsMover do
  let(:source) { FedoraMigrate.source.connection.find("sufia:rb68xc089") }

  subject { described_class.new(source.datastreams["rightsMetadata"], ExampleModel::MigrationObject.new) }

  it "displays the permissions from the source datastream" do
    expect(subject.edit_users).to include("jilluser@example.com")
  end
end
