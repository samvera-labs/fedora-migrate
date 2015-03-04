module FedoraMigrate
  class MigrationReport

    attr_accessor :results

    def initialize report=nil
      @results = report.nil? ? Hash.new : JSON.parse(File.read(report))
    end

    def empty?
      results.empty?
    end

    def failed_objects
      results.keys.map { |k| k unless results[k]["status"] }.compact
    end

    def failures
      failed_objects.count
    end

    def total_objects
      results.keys.count
    end

    def report_failures output = String.new
      failed_objects.each do |k|
        output << "#{k}:\n\tobject: #{results[k]["object"]}\n\trelationships: #{results[k]["relationships"]}\n\n"
      end
      output
    end

    def save path=nil
      json = JSON.load(results.to_json)
      file = path.nil? ? "report.json" : File.join(path,"report.json")
      File.write(file, JSON.pretty_generate(json))
    end

  end
end
