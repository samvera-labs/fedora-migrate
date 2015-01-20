require 'spec_helper'

describe FedoraMigrate::DatastreamVerification do

  class TestSubject
    include FedoraMigrate::DatastreamVerification
    def initialize datastream
      @datastream = datastream
    end
  end

  context "with matching checksums" do
    let(:mock_source) { double("Datastream", checksum: "foo") }
    subject do
      expect_any_instance_of(TestSubject).to receive(:target_checksum).once.and_return("foo")
      TestSubject.new(mock_source)
    end
    it { is_expected.to have_matching_checksums }
  end

  context "when the checksum is 'none'" do
    let(:mock_source) { double("Datastream", checksum: "none") }
    subject do
      TestSubject.new(mock_source)
    end
    it { is_expected.to have_no_checksum }
  end

  context "with equivalent content" do
    let(:mock_source) { double("Datastream", checksum: "bad", mimeType: "text/xml", content: "<bar></bar>") }
    subject do
      expect_any_instance_of(TestSubject).to receive(:target_content).once.and_return("<?xml version=\"1.0\"?>\n<bar></bar>")
      TestSubject.new(mock_source)
    end
    it { is_expected.to be_content_equivalent }
  end

end
