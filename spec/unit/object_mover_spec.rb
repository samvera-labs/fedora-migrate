require 'spec_helper'

describe FedoraMigrate::ObjectMover do
  let(:mock_target) { double("Target", id: "1234") }
  before { allow_any_instance_of(described_class).to receive(:target).and_return(mock_target) }

  describe "#new" do
    it { is_expected.to respond_to :source }
    it { is_expected.to respond_to :target }
    it { is_expected.to respond_to :post_initialize }
  end

  describe "#prepare_target" do
    subject { described_class.new("source", double("Target", id: nil)).prepare_target }
    it "calls the before hook and save the target" do
      expect_any_instance_of(described_class).to receive(:before_object_migration)
      expect(subject).to be nil
    end
  end

  describe "#complete_target" do
    subject { described_class.new("source", double("Target", id: nil)).complete_target }
    it "calls the after hook and save the target" do
      expect_any_instance_of(described_class).to receive(:after_object_migration)
      expect_any_instance_of(described_class).to receive(:save).and_return(true)
      expect(subject).to be true
    end
  end
end
