require 'spec_helper'

describe "The interface to Fedora3" do

  context "with an object's datastreams" do

    subject { FedoraMigrate.source.connection.find("sufia:rb68xc089") }

    it "should load them" do
      expect(subject.datastreams.count).to eql 8 
    end

    it "should see thier names" do
      expect(subject.datastreams.keys).to include("content")
    end

    it "should return their content" do
      expect(subject.datastreams["content"].content).to_not be_nil
    end

  end

end
