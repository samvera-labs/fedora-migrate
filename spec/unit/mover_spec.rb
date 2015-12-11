require 'spec_helper'

describe FedoraMigrate::Mover do
  it { is_expected.to respond_to :source }
  it { is_expected.to respond_to :target }
  it { is_expected.to respond_to :options }

  describe "#new" do
    context "with two arguments" do
      subject { described_class.new("foo", "bar") }
      specify "has a source" do
        expect(subject.source).to eql("foo")
      end
      specify "has a target" do
        expect(subject.target).to eql("bar")
      end
    end

    context "with options" do
      subject { described_class.new("foo", "bar", option: "optional") }
      specify "it has an option" do
        expect(subject.options).to eql(option: "optional")
      end
    end

    context "with optional arguments" do
      subject { described_class.new("foo") }
      specify "has a source" do
        expect(subject.source).to eql("foo")
      end
      specify "has a target" do
        expect(subject.target).to be_nil
      end
    end
  end

  describe "::id_component" do
    context "with a Rubydora object" do
      let(:id)      { "rb68xc11m" }
      let(:object)  { FedoraMigrate.source.connection.find("sufia:#{id}") }
      subject { described_class.id_component(object) }
      it { is_expected.to eql(id) }
    end
    context "with a URI" do
      let(:object)  { RDF::URI.new("foo:bar") }
      subject { described_class.id_component(object) }
      it { is_expected.to eql("bar") }
    end
    context "with a string" do
      let(:object)  { "foo:bar" }
      subject { described_class.id_component(object) }
      it { is_expected.to eql("bar") }
    end
  end

  describe "#id_component" do
    context "with a source" do
      subject { described_class.new("source:pid").id_component }
      it { is_expected.to eql("pid") }
    end
    context "object, but no source" do
      subject { described_class.new.id_component("source:pid") }
      it { is_expected.to eql("pid") }
    end
    context "neither object, nor source" do
      specify "raises an error" do
        expect { described_class.new.id_component }.to raise_error(FedoraMigrate::Errors::MigrationError)
      end
    end
  end
end
