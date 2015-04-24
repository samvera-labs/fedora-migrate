require 'spec_helper'

describe FedoraMigrate::RepositoryMigrator do

  let(:namespace) { "sufia" }

  it { is_expected.to respond_to(:source_objects) }
  it { is_expected.to respond_to(:report) }
  it { is_expected.to respond_to(:namespace) }

  describe "#failures" do
    context "when objects have failed to migrate" do
      let(:failing_report) { { "sufia:rb68xc089" => FedoraMigrate::RepositoryMigrator::SingleObjectReport.new(false, "objects", "relationships") } }
      before { allow_any_instance_of(FedoraMigrate::MigrationReport).to receive(:results).and_return(failing_report) }
      subject do
        migrator = FedoraMigrate::RepositoryMigrator.new(namespace)
        migrator.failures
      end
      it { is_expected.to be 1 }
    end
    context "when all objects have migrated" do
      let(:passing_report) { { "sufia:rb68xc089" => FedoraMigrate::RepositoryMigrator::SingleObjectReport.new(true, "objects", "relationships") } }
      before { allow_any_instance_of(FedoraMigrate::MigrationReport).to receive(:results).and_return(passing_report) }
      subject do
        migrator = FedoraMigrate::RepositoryMigrator.new(namespace)
        migrator.failures
      end
      it { is_expected.to eql 0 }
    end
  end

  describe "forcing relationship migration" do
    before do
      allow(subject).to receive(:source_objects).and_return([])
      allow(subject).to receive(:failures).and_return(1)
    end
    context "without an explicit force" do
      subject { FedoraMigrate::RepositoryMigrator.new(namespace) }
      it "should not migrate relationships" do
        expect(subject.migrate_relationships).to eql("Relationship migration halted because 1 objects didn't migrate successfully.")
      end
    end
    context "with an explicit force" do
      subject { FedoraMigrate::RepositoryMigrator.new(namespace, { force: true }) }
      it "should migrate relationships" do
        expect(subject.migrate_relationships).to_not be_nil
      end
    end
  end

  context "without a given namespace" do
    describe "#namespace" do
      specify "is given in the repository profile" do
        expect(subject.namespace).to eql("changeme")
      end
    end
  end

  context "with a given namespace" do
    subject { FedoraMigrate::RepositoryMigrator.new(namespace) }
    describe "#namespace" do
      specify "is the one provided" do
        expect(subject.namespace).to eql(namespace)
      end
    end
    describe "#source_objects" do
      it "should reuturn an array of all digital objects from Rubydora" do
        expect(subject.source_objects.collect { |o| o.pid }).to include("sufia:rb68xc089", "sufia:rb68xc11m")
      end
      it "should exclude fedora-system objects" do
        expect(subject.source_objects).to_not include("fedora-system:ContentModel-3.0")
        expect(subject.source_objects.count).to eql 9
      end
    end
  end

end
