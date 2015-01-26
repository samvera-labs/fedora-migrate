module FedoraMigrate
  class DatesMover < Mover

    def migrate
      if source.respond_to?(:createdDate) && target.respond_to?(:date_uploaded)
        target.date_uploaded = source.createdDate
      end
      if source.respond_to?(:lastModifiedDate) && target.respond_to?(:date_modified)
        target.date_modified = source.lastModifiedDate
      end
    end

  end
end
