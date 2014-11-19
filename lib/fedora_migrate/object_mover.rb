module FedoraMigrate
  class ObjectMover < Mover

    attr_accessor :conversions

    def migrate
      prepare_target
      migrate_content_datastreams
      conversions.collect { |ds| convert_rdf_datastream(ds) }
    end

    def post_initialize
      self.conversions = options.nil? ? [] : [options[:convert]].flatten
    end

    private

    def migrate_content_datastreams
      target.datastreams.keys.each do |ds|
        mover = FedoraMigrate::DatastreamMover.new(source.datastreams[ds], target.datastreams[ds])
        mover.migrate
      end
    end

    def convert_rdf_datastream ds
      if source.datastreams.keys.include?(ds)
        mover = FedoraMigrate::RDFDatastreamMover.new(source.datastreams[ds], target)
        mover.migrate
      end
    end

    def prepare_target
      create_target_model if target.nil?
      target.save
    end

    def create_target_model
      afmodel = source.models.map { |m| m if m.match(/afmodel/) }.compact.first.split(/:/).last
      @target = afmodel.constantize.new(id: source.id.split(/:/).last)
    end

  end
  
end
