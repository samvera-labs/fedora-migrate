module FedoraMigrate::Permissions

  # Taken from Hydra::AccessControls::Permissions under version 7.2.2
  #
  # We need the reader methods to get permissions from the Fedora3
  # rightsMetadata datastreams

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

end
