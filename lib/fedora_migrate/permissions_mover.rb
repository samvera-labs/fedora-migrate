module FedoraMigrate
  class PermissionsMover < Mover

    attr_accessor :rightsMetadata

    def post_initialize
      if source.respond_to?(:content)
        @rightsMetadata = datastream_from_content
      end
    end

    # TODO: create permissions module and call .each
    # on the methods.
    def migrate
      target.read_groups = self.read_groups
      target.edit_groups = self.edit_groups
      target.discover_groups = self.discover_groups
      target.read_users = self.read_users
      target.edit_users = self.edit_users
      target.discover_users = self.discover_users
      target.save
    end
      
    def read_groups
      rightsMetadata.groups.map {|k, v| k if v == 'read'}.compact
    end
    
    def edit_groups
      rightsMetadata.groups.map {|k, v| k if v == 'edit'}.compact
    end
          
    def discover_groups
      rightsMetadata.groups.map {|k, v| k if v == 'discover'}.compact
    end

    def read_users
      rightsMetadata.users.map {|k, v| k if v == 'read'}.compact
    end

    def edit_users
      rightsMetadata.users.map {|k, v| k if v == 'edit'}.compact
    end

    def discover_users
      rightsMetadata.users.map {|k, v| k if v == 'discover'}.compact
    end

    private

    def datastream_from_content ds = FedoraMigrate::RightsMetadata.new
      ds.ng_xml = source.content
      ds
    end

  end
end
