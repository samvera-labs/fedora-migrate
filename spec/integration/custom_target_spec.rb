require 'spec_helper'

describe FedoraMigrate::ObjectMover do
  let(:source) { FedoraMigrate.source.connection.find("sufia:rb68xc089") }
  let(:original_pid) { FedoraMigrate::Mover.id_component(source) }

  context "when we use our own target constructor" do
    let(:mover) { described_class.new source }

    before do
      # Override .build to use Fedora's default id minter
      class FedoraMigrate::TargetConstructor
        def build
          target.new
        end
      end

      Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      class GenericFile < ActiveFedora::Base
        has_subresource "content", class_name: "ExampleModel::VersionedDatastream"
        has_subresource "thumbnail", class_name: "ActiveFedora::File"
        has_subresource "characterization", class_name: "ActiveFedora::File"
      end
    end

    after do
      load './lib/fedora_migrate/target_constructor.rb'
    end

    subject do
      mover.migrate
      mover.target
    end

    it "migrates the entire object using a different id" do
      expect(subject.content.versions.all.count).to eql 3
      expect(subject.thumbnail.mime_type).to eql "image/jpeg"
      expect(subject.thumbnail.versions.all.count).to eql 0
      expect(subject.characterization.versions.all.count).to eql 0
      expect(subject).to be_kind_of GenericFile
      expect(subject.id).not_to eq(original_pid)
    end
  end
end
