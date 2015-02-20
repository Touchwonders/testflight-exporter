require 'fileutils'
require 'colored'


require_relative 'helpers'

# TODO: Workaround, since hockeyapp.rb from shenzhen includes the code for commander
def command(param)
end

module TestFlightExporter

  include Helper

  class HockeyAppUploader

    def run (token = nil, directory=nil)
      Helper.exit_with_error "Invalid API token. Use --token to specify your HockeyApp API token" if token.nil?
      Helper.exit_with_error "Invalid input folder. Use --input to specify an input folder" if directory.nil?


      Helper.log.info "Processing folder: #{directory}".blue

      require 'shenzhen'
      require 'shenzhen/plugins/hockeyapp'

      # Available options: http://support.hockeyapp.net/kb/api/api-versions#upload-version
      options = {
          status: 2
      }

      Dir.glob("#{directory}/**/*.ipa") { |filename|
        Helper.log.info "Starting with #{filename} upload to HockeyApp... this could take some time.".green

        notes = filename.gsub(/.ipa/,'.txt')

        File.open(notes) do |file|
          puts "merge #{File.read(file)}"
          options.merge!(notes: File.read(file))
        end

        raise "Symbols on path '#{File.expand_path(options[:dsym_filename])}' not found".red if (options[:dsym_filename] && !File.exists?(options[:dsym_filename]))

        client = Shenzhen::Plugins::HockeyApp::Client.new(token)
        response = client.upload_build(filename, options)
        case response.status
          when 200...300
            url = response.body['public_url']

            Helper.log.info "Public Download URL: #{url}".white if url
            Helper.log.info "Build successfully uploaded to HockeyApp!".green
          else
            Helper.log.fatal "Error uploading to HockeyApp: #{response.body}"
            Helper.exit_with_error "Error when trying to upload ipa to HockeyApp".red
        end
      }
    end

  end
end
