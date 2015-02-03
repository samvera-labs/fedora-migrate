module FedoraMigrate::DatastreamVerification
  
  attr_accessor :datastream

  def valid? datastream=nil
    @datastream = datastream || @source
    check = has_matching_checksums? || has_matching_nokogiri_checksums?
    FedoraMigrate::Logger.warn "#{@datastream.pid} datastream #{@datastream.dsid} validation failed" unless check
    check
  end

  def has_matching_checksums?
    datastream.checksum == target_checksum || checksum(datastream.content) == target_checksum
  end

  def has_matching_nokogiri_checksums?
    return false unless datastream.mimeType == "text/xml"
    checksum(Nokogiri::XML(datastream.content).to_xml) == checksum(Nokogiri::XML(target_content).to_xml)
  end

  private 

  def target_checksum
    target.digest.first.to_s.split(/:/).last
  end

  # In some cases, the data is in ldp_source but target.content is empty, so we check both places
  def target_content
    target.content.empty? ? target.ldp_source.content : target.content
  end

  def checksum content
    Digest::SHA1.hexdigest(content)
  end

end
