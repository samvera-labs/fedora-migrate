require 'spec_helper'

describe FedoraMigrate::Mover do

  it { is_expected.to respond_to :source }
  it { is_expected.to respond_to :target }

  describe "#new" do
    
    context "with all arguments" do
      subject { FedoraMigrate::Mover.new("foo", "bar") }
      specify "has a source" do
        expect(subject.source).to eql("foo")
      end
      specify "has a target" do
        expect(subject.target).to eql("bar")
      end
    end

    context "with optional arguments" do
      subject { FedoraMigrate::Mover.new("foo") }
      specify "has a source" do
        expect(subject.source).to eql("foo")
      end
      specify "has a target" do
        expect(subject.target).to be_nil
      end
    end

  end
end
