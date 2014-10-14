require 'spec_helper'

describe FedoraMigrate::TripleConverter do

  context "given an RDF triple / " do
    subject {  FedoraMigrate::TripleConverter.new('<info:fedora/sufia:xp68km39w> <http://purl.org/dc/terms/title> "Sample Migration Object A" .') }
    specify "it parses the triple for the object" do
      expect(subject.object).to eql "Sample Migration Object A"
    end
    specify "it parses the triple for the predicate" do
      expect(subject.predicate).to eql RDF::DC.title
    end
  end

  context "given a non-DC RDF triple / " do
    subject {  FedoraMigrate::TripleConverter.new( '<info:fedora/sufia:xp68km39w> <http://purl.org/dc/terms/baz> "Sample Migration Object A" .') }
    specify "it raises an error for the predicate" do
      expect{ subject.predicate }.to raise_error(NoMethodError)
    end
  end

  context "given a bad object / " do
    subject {  FedoraMigrate::TripleConverter.new( '<info:fedora/sufia:xp68km39w> <http://purl.org/dc/terms/title> Object not enclosed with quotes .') }
    specify "it raises an error" do
      expect{ subject.object }.to raise_error(StandardError)
    end
  end

end
