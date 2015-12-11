require 'spec_helper'

describe FedoraMigrate do
  context "with an object's datastreams" do
    subject { described_class.source.connection.find("sufia:rb68xc089") }

    it "loads them" do
      expect(subject.datastreams.count).to eql 8
    end

    it "sees thier names" do
      expect(subject.datastreams.keys).to include("content")
    end

    it "returns their content" do
      expect(subject.datastreams["content"].content).to_not be_nil
    end
  end
end
