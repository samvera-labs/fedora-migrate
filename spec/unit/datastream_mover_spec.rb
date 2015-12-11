require 'spec_helper'

describe FedoraMigrate::DatastreamMover do
  describe "#post_initialize" do
    specify "a target is required" do
      expect { subject.new }.to raise_error(StandardError)
    end
  end

  describe "#versionable?" do
    let(:versionable_target)     { instance_double("Target", versionable?: true) }
    let(:non_versionable_target) { instance_double("Target", versionable?: false) }

    context "by default" do
      subject { described_class.new("foo", "bar") }
      it { is_expected.to_not be_versionable }
    end
    context "when the datastream is not versionable" do
      subject { described_class.new("source", non_versionable_target) }
      it { is_expected.to_not be_versionable }
    end
    context "when the datastream is versionable" do
      subject { described_class.new("source", versionable_target) }
      it { is_expected.to be_versionable }
      context "but you want to override that" do
        subject do
          mover = described_class.new("source", versionable_target)
          mover.versionable = false
          return mover
        end
        it { is_expected.to_not be_versionable }
      end
    end
  end
end
