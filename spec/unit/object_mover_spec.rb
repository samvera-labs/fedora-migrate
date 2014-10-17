require 'spec_helper'

describe FedoraMigrate::ObjectMover do

    it { is_expected.to respond_to :source }
    it { is_expected.to respond_to :target }
    it { is_expected.to respond_to :post_initialize }

end
