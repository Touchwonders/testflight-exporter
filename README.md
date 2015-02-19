# TestFlight Exporter
**TL;DR**: TestFlight Exporter is a simple CLI tool that downloads archived builds from your TestFlightapp.com account.

After years of faithful service, the original TestFlight is closing down on February 26th 2015. To ease the transition to a new beta distribution system, TestFlight provides a way to export existing teams and testers. A way to download your .ipa files, however, is lacking. That's where TestFlightExporter comes in!

TestFlight Exporter can download the builds, including release notes, from your account and stores them in a nice folder structure on your local machine.

## Installation

TestFlight Exporter is available as a gem, which you can easily install by executing the following command in your terminal:

    $ gem install TestFlightExporter

## Usage

TestFlight Exporter is available as a simple CLI tool.
You can invoke it by typing `tfexporter` on your terminal.

Follow the setup assistent, which will configure the current TestFlight Exporter run to your needs. All selected builds and release notes will be saved in a folder named `out`.

**Warning**: Depending on the number of builds you have in your TestFlight account, TestFlight Exporter could consume a lot of data/bandwidth.

## How does this thing work?

TestFlight doesn't provide any API to perform such task like exporting your .ipa's. TestFlight Exporter uses [mechanize](https://github.com/sparklemotion/mechanize) to  automatically find and follow the download links on the TestFlight website.

TestFlight Exporter uses your credentials to access your TestFlight account (over https). Other than that, your credentials do not leave your machine.

## Incorporating TestFlight Exporter into your project
If you want to use the functionality of TestFlight Exporter directly rather than as a command-line tool, you can include it into your ruby product and use it from your code.

To include it in your project, add this line to your application's Gemfile:

```ruby
gem 'TestFlightExporter'
```

And then execute:

    $ bundle install

## License

TestFlight exporter is available under the MIT license. See the LICENSE file for more info.