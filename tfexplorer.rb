#!/usr/bin/env ruby

 require 'mechanize'
 require 'fileutils'

  @agent = Mechanize.new

  def process_login_page page

    puts 'Login...'

    login_form = page.forms.first # by pretty printing the page this is safe catch

    login_field = login_form.field_with(:name => 'username')
    password_field = login_form.field_with(:name => 'password')

    login_field.value = 'fabio@touchwonders.com'
    password_field.value = 'touchwondersworld'

    login_form.submit

    puts 'Dashboard...'

    team_list = Hash.new
    @current_team = String.new

    @agent.get("https://testflightapp.com/dashboard/applications/") do |dashboard_page|
      dashboard_page.links.each do |ll|
        # Retrieve current team
        if ll.attributes.attributes['class']
          @current_team = ll if ll.attributes.attributes['class'].text.eql? "dropdown-toggle team-menu"
        end

        # Retrieve other team id list
        team_list.merge!({ll.attributes['data-team-id']=>ll.text}) if ll.attributes['data-team-id']
      end

      # process current team
      puts "Processing team: #{@current_team}"
      
      process_dashboard_page dashboard_page

      # process other teams
      team_list.each do |team_id, team_name|
        team_switch = dashboard_page.forms.first 
        team_id_field = team_switch.field_with(:name => 'team')
        team_id_field.value = team_id
        team_switch.submit  
        @current_team = team_name

        process_dashboard_page @agent.get("https://testflightapp.com/dashboard/applications/")
      end
      
    end
  end

  def process_dashboard_page dashboard_page
    app_link_pattern = /\/dashboard\/applications\/(.*?)\/token\//
    dashboard_page.links.each do |link|
      link.href =~ app_link_pattern
      if $1 != nil
        puts "Builds page for #{$1}..." 
        @agent.get "https://testflightapp.com/dashboard/applications/#{$1}/builds/" do |builds_page|
          
          # Collection of all pages for current build
          inner_pages = Array.new

          builds_page.links.each do |ll|
            inner_pages.push(ll.href) if ll.href =~ /\?page=*/ unless inner_pages.include?(ll.href)
          end

          number_of_pages = inner_pages.count + 1
          puts "Processing page 1 of #{number_of_pages}"
          puts ""

          # Process current build page
          process_builds_page builds_page

          # Cycle over remaning build pages
          i = 2
          inner_pages.each do |page|
            puts ""
            puts "Processing page #{i} of #{number_of_pages}"
            
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

    puts "RELEASE NOTE"
    puts release_note

    ipa_link = page.link_with(:text => "download the IPA.")
    ipa_link = ipa_link = page.link_with(:text => "download the IPA") if ipa_link.nil?
    
    if ipa_link.nil?
      puts "No IPA link found. Do you have permission for current application?"
    else
      download_build(ipa_link, "ipa", release_note)
    end
    
    puts ""
  end

  def download_build link, file_ext, release_note

    link.href =~ /\/dashboard\/ipa\/(.*?)\//
    filename = "#{$1}.#{file_ext}"

    file_url = "https://www.testflightapp.com#{link.href}"
    puts "Downloading #{file_url}..."

    dirname = File.dirname("out/#{@current_team}")
    
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

    dirname = File.dirname("out/#{@current_team}/#{@app_name}")
    
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)    

    @agent.get(file_url).save("out/#{@current_team}/#{@app_name}/#{filename}")
    File.open("out/#{@current_team}/#{@app_name}/#{$1}.txt", 'w') {|f| f.write(release_note) }
  end

  FileUtils.rm_rf "out"
  Dir.mkdir "out"

  login_page_url = "https://testflightapp.com/login/"
  @agent.get(login_page_url) { |page| process_login_page page }