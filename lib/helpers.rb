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

      @@log
    end

  end
end