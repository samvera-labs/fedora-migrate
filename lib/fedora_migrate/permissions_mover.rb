module FedoraMigrate
  class PermissionsMover < Mover

    include FedoraMigrate::Permissions

    attr_accessor :rightsMetadata

    def post_initialize
      if source.respond_to?(:content)
        @rightsMetadata = datastream_from_content
      end
    end

    def migrate
      FedoraMigrate::Permissions.instance_methods.each do |permission|
        Logger.info "setting #{permission} to #{self.send(permission)}"
        target.send(permission.to_s+"=", self.send(permission))
      end
      save
    end


    private

    def datastream_from_content ds = FedoraMigrate::RightsMetadata.new
      ds.ng_xml = source.content
      ds
    end

  end
end
