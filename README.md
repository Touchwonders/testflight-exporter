# Test Flight Exporter
TL;DR: Test Flight Exporter is a simple CLI tool written in Ruby which helps you to download your TestFlight builds.

After so long distinguished service TestFlight is giving his last breathe, before becoming part of iTunes Connect platform, on February 26th.
Test Flight Exporter has been developed in willing to cover an important missing gap in the transition to a new solution: download,
on your local machine, all uploaded builds your account has access to.

## Installation

If you are familiar with the command line and Ruby, install Test Flight exporter yourself:

    $ gem install testflight_exporter

To include it in your project, add this line to your application's Gemfile:

```ruby
gem 'testflight_exporter'
```

And then execute:

    $ bundle install

## Usage

Test Flight exporter is available as a simple CLI tool.
You can invoke it by typing `tfexporter` on your terminal.

Follow the setup assistent, which will tailor Test Flight exporter to your needs.

## How does this thing work?

Test Flight doesn't provide any API to perform such task like exporting your IPA.
By using `mechanize` we made the access to Test Flight website automated:

* Mechanize automatically stores and sends cookies, follows redirects, links and submit forms for you.
* Testflight exporter process your input and interacts with Test Flight dashboard in order to accomplish his duty.

Fire Test Flight Exporter and grab a coffee, it will do things for you.

## License

TestFlight exporter is available under the MIT license. See the LICENSE file for more info.