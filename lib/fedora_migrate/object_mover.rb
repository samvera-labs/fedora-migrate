module FedoraMigrate
  class ObjectMover < Mover

    def migrate
      prepare_target
      target.datastreams.keys.each do |ds|
        mover = datastream_mover(ds)
        mover.migrate
      end
    end

    private

    def datastream_mover ds
      FedoraMigrate::DatastreamMover.new( source.datastreams[ds], target.datastreams[ds])
    end

    def prepare_target
      create_target_model if target.nil?
      target.save
    end

    def create_target_model
      afmodel = source.models.map { |m| m if m.match(/afmodel/) }.compact.first.split(/:/).last
      @target = afmodel.constantize.new(pid: source.pid.split(/:/).last)
    end

  end
  
end
