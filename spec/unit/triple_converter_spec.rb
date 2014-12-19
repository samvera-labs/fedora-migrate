require 'spec_helper'

describe FedoraMigrate::TripleConverter do

  context "given an RDF triple / " do
    subject {  FedoraMigrate::TripleConverter.new('<info:fedora/sufia:xp68km39w> <http://purl.org/dc/terms/title> "Sample Migration Object A" .') }
    specify "it parses the triple for the object" do
      expect(subject.object).to eql "Sample Migration Object A"
    end
    specify "it parses the triple for the predicate" do
      expect(subject.predicate).to eql ::RDF::DC.title
    end
  end

  context "given a non-DC RDF triple / " do
    subject {  FedoraMigrate::TripleConverter.new( '<info:fedora/sufia:xp68km39w> <http://purl.org/dc/terms/baz> "Sample Migration Object A" .') }
    before do
      expect(FedoraMigrate::Logger).to receive(:warn)
    end
    specify "it returns a null predicate" do
      expect(subject.predicate).to be nil
    end
  end

  context "given a malformed triple / " do
    before do
      expect(FedoraMigrate::Logger).to receive(:warn)
    end
    subject {  FedoraMigrate::TripleConverter.new( '<info:fedora/sufia:xp68km39w> <http://purl.org/dc/terms/title> Object not enclosed with quotes .') }
    specify "it returns a nul object" do      
      expect(subject.object).to be nil      
    end
  end

end
