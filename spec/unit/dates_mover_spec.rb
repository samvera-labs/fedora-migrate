require 'spec_helper'

describe FedoraMigrate::DatesMover do
  let(:target) { ExampleModel::RDFObject.new }
  let(:source) { instance_double('Source', createdDate: 'yesterday', lastModifiedDate: 'today') }

  subject { described_class.new(source, target) }

  describe '#migrate' do
    it 'migrates the create and mod dates' do
      subject.migrate
      expect(target.date_uploaded).to eq 'yesterday'
      expect(target.date_modified).to eq 'today'
    end

    context "when the source methods don't exist" do
      let(:source) { instance_double('Source with no date methods') }
      it 'gracefully does nothing' do
        expect { subject.migrate }.not_to raise_error
        expect(target.date_uploaded).to be_nil
        expect(target.date_modified).to be_nil
      end
    end

    context "when the target methods don't exist" do
      let(:target) { instance_double('Target with no date methods') }
      it 'gracefully does nothing' do
        expect { subject.migrate }.not_to raise_error
      end
    end
  end
end
