require 'spec_helper'

describe FedoraMigrate::TargetConstructor do
  let(:mock_source) { instance_double("Source", models: list, pid: "pid:1234") }
  context "with one qualified model" do
    let(:list) { ["info:fedora/fedora-system:FedoraObject-3.0", "info:fedora/afmodel:String"] }
    subject { described_class.new(mock_source) }
    its(:target) { is_expected.to eql String }
  end

  context "with multiple qualified models" do
    let(:list) { ["info:fedora/fedora-system:FedoraObject-3.0", "info:fedora/afmodel:Array", "info:fedora/afmodel:String"] }
    subject { described_class.new(mock_source) }
    its(:target) { is_expected.to eql Array }
  end

  context "with a single qualified model" do
    let(:list) { "info:fedora/afmodel:Array" }
    subject { described_class.new(mock_source) }
    its(:target) { is_expected.to eql Array }
  end

  context "with multiple unqualified models" do
    let(:list) { ["info:fedora/fedora-system:FedoraObject-3.0", "info:fedora/fedora-system:FooObject"] }
    subject { described_class.new(mock_source) }
    its(:target) { is_expected.to be_nil }
  end

  context "with a namespaced model" do
    let(:list) { "info:fedora/afmodel:Enumerator_Lazy" }
    subject { described_class.new(mock_source) }
    its(:target) { is_expected.to eql Enumerator::Lazy }
  end
end
