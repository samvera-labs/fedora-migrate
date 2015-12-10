module FedoraMigrate
  class DatesMover < Mover
    Report = Struct.new(:uploaded, :modified)

    def migrate
      migrate_date_uploaded if source.respond_to?(:createdDate) && target.respond_to?(:date_uploaded)
      migrate_date_modified if source.respond_to?(:lastModifiedDate) && target.respond_to?(:date_modified)
      super
    end

    def results_report
      Report.new
    end

    def migrate_date_uploaded
      target.date_uploaded = source.createdDate
      report.uploaded = source.createdDate
    end

    def migrate_date_modified
      target.date_modified = source.lastModifiedDate
      report.modified = source.lastModifiedDate
    end
  end
end
