require 'spec_helper'

describe FedoraMigrate::RubydoraConnection do
  describe 'initialize' do

    let (:fedora_url) { "http://my.fedora3.instance" }

    subject {
      FedoraMigrate::RubydoraConnection.new timeout: 3600, validateChecksum: true, url: fedora_url
    }

    specify "a timeout" do
      expect(subject.connection.client.options[:timeout]).to eql(3600)
    end
      
    specify "validate a checksum" do
      expect(subject.connection.config[:validateChecksum]).to be true
    end

    specify "a Fedora3 url" do
      expect(subject.connection.client.url).to eql fedora_url
    end

  end
end
