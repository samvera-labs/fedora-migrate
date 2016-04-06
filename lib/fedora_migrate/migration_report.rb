module FedoraMigrate
  class MigrationReport
    attr_accessor :path, :results

    DEFAULT_PATH = "migration_report".freeze

    def initialize(path = nil)
      @path = path.nil? ? DEFAULT_PATH : path
      FileUtils.mkdir_p(@path)
      reload
    end

    def reload
      @results = load_results_from_directory
    end

    delegate :empty?, to: :results

    def failed_objects
      results.keys.map { |k| k unless results[k]["status"] }.compact
    end

    def failures
      failed_objects.count
    end

    def total_objects
      results.keys.count
    end

    def report_failures(output = '')
      failed_objects.each do |k|
        output << "#{k}:\n\tobject: #{results[k]['object']}\n\trelationships: #{results[k]['relationships']}\n\n"
      end
      output
    end

    # Receives and individual report and writes it to the MigrationReport directory
    def save(pid, report)
      file = File.join(path, file_from_pid(pid))
      json = JSON.load(report.to_json)
      File.write(file, JSON.pretty_generate(json))
    end

    private

      def load_results_from_directory(assembled = {})
        Dir.glob(File.join(path, "*.json")).each do |file|
          assembled[pid_from_file(file)] = JSON.parse(File.read(file))
        end
        assembled
      end

      def pid_from_file(file)
        File.basename(file, ".*").tr('_', ":")
      end

      def file_from_pid(pid)
        pid.tr(':', "_") + ".json"
      end
  end
end
