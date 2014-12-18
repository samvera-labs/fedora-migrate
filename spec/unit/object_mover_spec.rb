require 'spec_helper'

describe FedoraMigrate::ObjectMover do

  before do
    allow_any_instance_of(FedoraMigrate::ObjectMover).to receive(:create_target_model).and_return("foo")
  end

  describe "#new" do

    it { is_expected.to respond_to :source }
    it { is_expected.to respond_to :target }
    it { is_expected.to respond_to :post_initialize }
  end

  describe "#prepare_target" do
    subject do
      FedoraMigrate::ObjectMover.new("source", "target").prepare_target
    end
    it "should call the before hook and save the target" do
      expect_any_instance_of(FedoraMigrate::ObjectMover).to receive(:before_object_migration)
      expect_any_instance_of(FedoraMigrate::ObjectMover).to receive(:save).and_return(true)
      expect(subject).to be true
    end
  end

  describe "#complete_target" do
    subject do
      FedoraMigrate::ObjectMover.new("source", "target").complete_target
    end
    it "should call the after hook and save the target" do
      expect_any_instance_of(FedoraMigrate::ObjectMover).to receive(:after_object_migration)
      expect_any_instance_of(FedoraMigrate::ObjectMover).to receive(:save).and_return(true)
      expect(subject).to be true
    end
  end

end
