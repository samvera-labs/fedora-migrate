require 'spec_helper'

describe FedoraMigrate::FileConfigurator do
  subject { FedoraMigrate.configurator }

  describe "#fedora3_config" do
    it "uses the values from the yml file" do
      expect(subject.fedora3_config[:user]).to eql "fedoraAdmin"
      expect(subject.fedora3_config[:password]).to eql "fedoraAdmin"
      expect(subject.fedora3_config[:url]).to eql "http://localhost:8983/fedora3"
    end
  end
end
