require 'mechanize'
require 'fileutils'
require 'colored'

require_relative 'helpers'

module TestFlightExporter

  include Helper

  class Setup

    def initialize
      @agent = Mechanize.new
      @current_team = String.new
      @team_list = Hash.new
    end

    def setup
      "Welcome to Osiris Migration Tool."
      puts "Before we start I need some information about your TestFlight account."

      @username = ask("Enter your TestFlight username:  ") { |q| q.echo = true }
      @password = ask("Enter your TestFlight password:  ") { |q| q.echo = "*" }

      #clean up
      # TODO: do not remove the folder at all
      #       If it is already there than quit with message (ERROR)

      FileUtils.rm_rf "out"
      Dir.mkdir "out"

      login_page_url = "https://testflightapp.com/login/"


      @agent.get(login_page_url) { |page| process_login_page page }

    end

    def process_login_page page

      Helper.log.info 'Login...'.yellow

      login_form = page.forms.first # by pretty printing the page this is safe catch

      login_field = login_form.field_with(:name => 'username')
      password_field = login_form.field_with(:name => 'password')

      login_field.value = @username
      password_field.value = @password

      login_form.submit

      name = @username[/[^@]+/]
      name.split(".").map {|n| n.capitalize }.join(" ")

      # TODO menu item list with number reference and all times reference

      @agent.get("https://testflightapp.com/dashboard/applications/") do |dashboard_page|

        @dashboard_page = dashboard_page

        dashboard_page.links.each do |ll|
          # Retrieve current team
          if ll.attributes.attributes['class']
            @current_team = ll if ll.attributes.attributes['class'].text.eql? "dropdown-toggle team-menu"
          end

          # Retrieve other team id list
          @team_list.merge!({ll.text=>ll.attributes['data-team-id']}) if ll.attributes['data-team-id']
        end

        if (!response && required_team_name)
          if @current_team.eql? required_team_name
            # process current team
            Helper.log.info "Processing team: #{@current_team}".blue

            process_dashboard_page dashboard_page
            return
          else
            if @team_list["#{required_team_name}"].nil?
              puts "Sorry, I can\'t find #{required_team_name} in your teams.".red
              return
            end

            switch_to_team_id @team_list["#{required_team_name}"]

            @current_team = required_team_name
            # process current team
            Helper.log.info "Processing team: #{@current_team}".blue

            process_dashboard_page @agent.get("https://testflightapp.com/dashboard/applications/")
            return
          end
        end

        # process current team
        puts ""
        Helper.log.info "This could take a while... ☕️".green #TODO every time it is working! And new line!
        Helper.log.info "Processing team: #{@current_team}".blue

        process_dashboard_page dashboard_page

        # process other teams
        @team_list.each do |team_name, team_id|
          switch_to_team_id team_id
          @current_team = team_name
          process_dashboard_page @agent.get("https://testflightapp.com/dashboard/applications/")
        end

      end
    end

    def switch_to_team_id team_id
      team_switch = @dashboard_page.forms.first
      team_id_field = team_switch.field_with(:name => 'team')
      team_id_field.value = team_id
      team_switch.submit
    end

    def process_dashboard_page dashboard_page
      app_link_pattern = /\/dashboard\/applications\/(.*?)\/token\//
      dashboard_page.links.each do |link|
        link.href =~ app_link_pattern
        if $1 != nil
          # Helper.log.info "Builds page for #{$1}..."
          @agent.get "https://testflightapp.com/dashboard/applications/#{$1}/builds/" do |builds_page|

            # Collection of all pages for current build
            inner_pages = Array.new

            builds_page.links.each do |ll|
              inner_pages.push(ll.href) if ll.href =~ /\?page=*/ unless inner_pages.include?(ll.href)
            end

            number_of_pages = inner_pages.count + 1
            Helper.log.info "Page 1 of #{number_of_pages}".magenta # DEBUG
            puts ""

            # Process current build page
            process_builds_page builds_page

            # Cycle over remaning build pages
            i = 2
            inner_pages.each do |page|
              puts ""
              Helper.log.info "Page #{i} of #{number_of_pages}".magenta # DEBUG

              process_builds_page @agent.get "https://testflightapp.com#{page}"

              i = i+1
            end

          end
        end
      end
    end

    def process_builds_page page
      body = page.body
      build_pages = body.scan /<tr class="goversion pointer" id="\/dashboard\/builds\/report\/(.*?)\/">/

      build_pages.each do |build_id|
        @agent.get "https://testflightapp.com/dashboard/builds/complete/#{build_id.first}/" do |build_page|
          # Retrieve current app name
          @app_name = page.at("h2").text

          process_build_page build_page
        end
      end
    end

    def process_build_page page
      build_link = page.links_with(:dom_class => 'bitly').first
      @agent.get("https://www.testflightapp.com#{build_link.href}") { |install_page| process_install_page install_page}
    end

    def process_install_page page
      # we need to figure out what kind of build is that
      release_note = page.search('.clearfix').at("p").text

      puts "RELEASE NOTE" # DEBUG
      puts release_note # DEBUG

      ipa_link = page.link_with(:text => "download the IPA.")
      ipa_link = page.link_with(:text => "download the IPA") if ipa_link.nil?

      if ipa_link.nil?
        Helper.log.error "No IPA link found. Do you have permission for current application?".red
      else
        download_build(ipa_link, "ipa", release_note)
      end

      puts ""
    end

    def download_build link, file_ext, release_note

      link.href =~ /\/dashboard\/ipa\/(.*?)\//
      filename = "#{$1}.#{file_ext}"

      file_url = "https://www.testflightapp.com#{link.href}"
      puts "Downloading #{file_url}..." # DEBUG

      dirname = File.dirname("#{@path}/#{@current_team}")

      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

      dirname = File.dirname("#{@path}/#{@current_team}/#{@app_name}")

      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

      @agent.get(file_url).save("#{@path}/#{@current_team}/#{@app_name}/#{filename}")
      File.open("#{@path}/#{@current_team}/#{@app_name}/#{$1}.txt", 'w') {|f| f.write(release_note) }
    end
  end
end
