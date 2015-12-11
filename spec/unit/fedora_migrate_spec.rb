require 'spec_helper'

describe FedoraMigrate do
  describe "Fedora3 / " do
    describe "configuration" do
      subject { described_class.fedora_config }
      it { is_expected.to be_kind_of ActiveFedora::Config }
    end

    describe "connection" do
      subject { described_class.source }
      it { is_expected.to be_kind_of FedoraMigrate::RubydoraConnection }
    end
  end
end
