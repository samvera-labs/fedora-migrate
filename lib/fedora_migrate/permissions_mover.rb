module FedoraMigrate
  class PermissionsMover < Mover
    include FedoraMigrate::Permissions

    attr_accessor :rightsMetadata

    def post_initialize
      @rightsMetadata = datastream_from_content if source.respond_to?(:content)
    end

    def migrate
      FedoraMigrate::Permissions.instance_methods.each do |permission|
        report << "#{permission} = #{send(permission)}"
        target.send(permission.to_s + "=", send(permission))
      end
      save
      super
    end

    private

      def datastream_from_content(ds = FedoraMigrate::RightsMetadata.new)
        ds.ng_xml = source.content
        ds
      end
  end
end
