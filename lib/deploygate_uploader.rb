# TODO: Workaround, since deploygate.rb from shenzhen includes the code for commander
def command(_param)
end

module TestFlightExporter

  class DeployGateUploader
    DEPLOYGATE_URL_BASE = 'https://deploygate.com'

    def self.run(params)
      Helper.exit_with_error "Invalid user. Use --username to specify a valid username" if params.username.nil?
      Helper.exit_with_error "Invalid API token. Use --token to specify your DeployGate API token" if params.token.nil?
      Helper.exit_with_error "Invalid input folder. Use --input to specify an input folder" if params.input.nil?

      username = params.username
      token = params.token
      directory = params.input

      require 'shenzhen'
      require 'shenzhen/plugins/deploygate'


      Helper.log.info 'Starting with ipa upload to DeployGate... this could take some time ⏳'.green


      client = Shenzhen::Plugins::DeployGate::Client.new(
          token,
          username
      )

      number_of_builds = 0

      Dir.glob("#{directory}/**/*.ipa") { |filename|

        Helper.log.debug "Starting with #{filename} upload to DeployGate...".magenta

        notes = filename.gsub(/.ipa/,'.txt')

        # Available options: https://deploygate.com/docs/api
        options = nil
        File.open(notes) do |file|
          options = { message: File.read(file) }
        end

        response = client.upload_build(filename, options)
        if parse_response(response)
          Helper.log.debug"Public Download URL: #{@url_success}".white if @url_success
          Helper.log.debug "Build successfully uploaded to DeployGate!".green
          number_of_builds = number_of_builds + 1
        else
          Helper.exit_with_error 'Error when trying to upload ipa to DeployGate'.red
        end
      }
      Helper.log.info "Uploaded #{number_of_builds} binaries on DeployGate platform!".blue

    end

    def self.parse_response(response)
      if response.body && response.body.key?('error')
        unless response.body['error']
          res = response.body['results']
          url = DEPLOYGATE_URL_BASE + res['path']

          @url_success = url
        else
          Helper.log.error "Error uploading to DeployGate: #{response.body['message']}".red
          help_message(response)
          return
        end
      else
        Helper.exit_with_error "Error uploading to DeployGate: #{response.body}".red
      end
      true
    end
    private_class_method :parse_response

    def self.help_message(response)
      message =
          case response.body['message']
            when 'you are not authenticated'
              'Invalid API Token specified.'
            when 'application create error: permit'
              'Access denied: May be trying to upload to wrong user or updating app you join as a tester?'
            when 'application create error: limit'
              'Plan limit: You have reached to the limit of current plan or your plan was expired.'
          end
      Helper.log.error message.red if message
    end
    private_class_method :help_message
  end
end
