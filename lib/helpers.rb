require 'logger'


class String
  def classify
    self.split('_').collect!{ |w| w.capitalize }.join
  end
end



module TestFlightExporter
  module Helper

    # Logging happens using this method
    def self.log
      @@log ||= Logger.new(STDOUT)

      @@log.formatter = proc do |severity, datetime, progname, msg|
        string = "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%2N')}]: "
        second = "#{msg}\n"

        if severity == "DEBUG"
          string = string.magenta
        elsif severity == "INFO"
          string = string.white
        elsif severity == "WARN"
          string = string.yellow
        elsif severity == "ERROR"
          string = string.red
        elsif severity == "FATAL"
          string = string.red.bold
        end


        [string, second].join("")
      end

      @@log.level = Logger::INFO
      @@log.level = Logger::DEBUG if is_log_verbose?

      @@log
    end

    def self.is_log_verbose?
      ENV['VERBOSE_MODE']
    end

    # EXIT HANDLERS

    # Print error text with error format and exit with in input error_code (default=1)
    def self.exit_with_error (message, error_code=1)
      log.error message.red
      exit (error_code)
    end
  end
end