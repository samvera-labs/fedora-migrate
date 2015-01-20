module FedoraMigrate::DatastreamVerification
  
  attr_accessor :datastream

  def valid? datastream=nil
    @datastream = datastream || @source
    check = has_no_checksum? || has_matching_checksums? || content_equivalent?
    FedoraMigrate::Logger.warn "#{@datastream.pid} datastream #{@datastream.dsid} validation failed" unless check
    check
  end

  def has_matching_checksums?
    datastream.checksum == target_checksum
  end

  # TODO: Reporting mechanism? If there isn't a checksum it defaults to "none" (issue #4)
  def has_no_checksum?
    if datastream.checksum == "none"
      FedoraMigrate::Logger.info "unable to vaidate datastream because the checksum was 'none'"
      return true
    end
  end
  
  # TODO: In some cases, the line <?xml version="1.0"?> is being added to migrated xml datastreams.
  # This invalidates the checksum even though the xml content is the same. (issue #11)
  def content_equivalent?
    if datastream.mimeType == "text/xml"
      EquivalentXml.equivalent?(target_content, datastream.content)
    end
  end

  private 

  def target_checksum
    target.digest.first.to_s.split(/:/).last
  end

  # In some cases, the data is in ldp_source but target.content is empty, so we check both places
  def target_content
    target.content.empty? ? target.ldp_source.content : target.content
  end

end
