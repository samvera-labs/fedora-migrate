require 'spec_helper'

describe FedoraMigrate::DatastreamMover do

  it { is_expected.to respond_to :source }
  it { is_expected.to respond_to :target }
  it { is_expected.to respond_to :versionable }

  describe "#is_versionable?" do
    let(:versionable_migrator) { FedoraMigrate::DatastreamMover.new(versionable: true) }
    specify "defaults to false" do
      expect(subject.is_versionable?).to be false
    end
    specify "can be true" do
       expect(versionable_migrator.is_versionable?).to be true
    end
  end

end
