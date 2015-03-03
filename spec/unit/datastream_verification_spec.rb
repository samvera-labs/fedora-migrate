require 'spec_helper'

describe FedoraMigrate::DatastreamVerification do

  class TestSubject
    include FedoraMigrate::DatastreamVerification
    def initialize datastream
      @datastream = datastream
      @source = datastream
    end
  end

  describe "binary sources from Fedora3" do
    let(:bad_binary_source)     { double("Datastream", checksum: "bad",     mimeType: "binary", content: "XXXXXX", dsid: "content", pid: "abc123") }
    let(:good_binary_source)    { double("Datastream", checksum: "foo",     mimeType: "binary", content: "foo",    dsid: "content", pid: "abc123") }
    let(:missing_checksum)      { double("Datastream", checksum: "missing", mimeType: "binary", content: "foo",    dsid: "content", pid: "abc123") }
    context "that match Fedora4's checksum" do
      subject { TestSubject.new(good_binary_source) }
      before  { allow(subject).to receive(:target_checksum).once.and_return("foo") }
      it      { is_expected.to have_matching_checksums }
      it      { is_expected.to be_valid }
    end
    context "that do not match Fedora4's checksum" do
      subject { TestSubject.new(bad_binary_source) }
      before  { allow(subject).to receive(:target_checksum).twice.and_return("bar") }
      it      { is_expected.to_not be_valid }
    end
    context "when the checksum is missing" do
      subject { TestSubject.new(missing_checksum) }
      context "and a newly calculated checksum matches" do
        before { allow(subject).to receive(:target_checksum).twice.and_return(Digest::SHA1.hexdigest("foo")) }
        it     { is_expected.to have_matching_checksums }
        it     { is_expected.to be_valid }
      end
      context "and a newly calculated checksum does not match" do
        before { expect_any_instance_of(TestSubject).to receive(:target_checksum).twice.and_return(Digest::SHA1.hexdigest("bar")) }
        it     { is_expected.to_not be_valid }
      end
    end
  end

  describe "xml sources from Fedora3" do
    subject { TestSubject.new(double("Datastream", checksum: "invalid", mimeType: "text/xml", content: "<bar></bar>")) }
    context "when the datastream content is correctly altered upon migration" do
      before  { allow(subject).to receive(:target_content).once.and_return("<?xml version=\"1.0\"?>\n<bar></bar>") }
      it      { is_expected.to have_matching_nokogiri_checksums }
    end
    context "when the datastream content is incorrectly altered upon migration" do
      before { allow(subject).to receive(:target_content).once.and_return("<?xml version=\"1.0\"?>\n<baz></baz>") }
      it     { is_expected.to_not have_matching_nokogiri_checksums }
    end
  end

end
