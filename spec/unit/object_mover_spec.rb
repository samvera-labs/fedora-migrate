require 'spec_helper'

describe FedoraMigrate::ObjectMover do

  context "with a correct configuration" do
    subject { FedoraMigrate::ObjectMover.new "sufia:rb68xc089", ActiveFedora::Base.new }
    it { is_expected.to respond_to :source }
    it { is_expected.to respond_to :target }
  end

end
