require 'fileutils'
require 'colored'


require_relative 'helpers'

# TODO: Workaround, since hockeyapp.rb from shenzhen includes the code for commander
def command(param)
end

module TestFlightExporter

  include Helper

  class HockeyAppUploader

    def run (token = nil, directory=nil, teams=nil)
      Helper.exit_with_error "Invalid API token. Use --token to specify your HockeyApp API token" if token.nil?
      Helper.exit_with_error "Invalid input folder. Use --input to specify an input folder" if directory.nil?

      require 'shenzhen'
      require 'shenzhen/plugins/hockeyapp'

      # Available options: http://support.hockeyapp.net/kb/api/api-versions#upload-version
      options = {
          status: 2
      }

      options.merge!(teams: teams) unless teams.nil?

      Helper.log.info "Uploadind binaries to Hockeyapp platform... this could take some time.".blue

      Dir.glob("#{directory}/**/*.ipa") { |filename|

        Helper.log.debug "Starting with #{filename} upload to HockeyApp...".magenta

        notes = filename.gsub(/.ipa/,'.txt')

        File.open(notes) do |file|
          options.merge!(notes: File.read(file))
        end

        client = Shenzhen::Plugins::HockeyApp::Client.new(token)
        response = client.upload_build(filename, options)
        case response.status
          when 200...300
            url = response.body['public_url']

            Helper.log.debug"Public Download URL: #{url}".white if url
            Helper.log.debug "Build successfully uploaded to HockeyApp!".green
          else
            Helper.log.error "Error uploading to HockeyApp: #{response.body}"
            Helper.exit_with_error "Error when trying to upload ipa to HockeyApp".red
        end
      }
    end

  end
end
