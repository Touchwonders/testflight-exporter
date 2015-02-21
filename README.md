<h3 align="center">
  <a href="http://www.touchwonders.com"><img src="assets/tw_logo.png" alt="Touchwonders Logo" style="width:35%;"/></a>
</h3>

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

Follow the setup assistent, which will configure the current TestFlight Exporter run to your needs. All selected builds and release notes will be saved in output folder specified by you.

Like all the CLI tool TestFlight Exporter comes with global options that you can use to fire the tool and take a break for a good coffee :coffee: .
Launch TestFlight exporter with `--help` option to have a quick overview about all of them.

**Warning**: Depending on the number of builds you have in your TestFlight account, TestFlight Exporter could consume a lot of data/bandwidth. Use

    $ tfexplorer --max [MAX_NUMBER]

to limit number of downloaded binaries per build.

### HockeyApp integration

Since version 0.2.0 TestFlight exporter supports the upload of your downloaded binaries on HockeyApp platform.
Execute the following command in your terminal:

    $ tfexporter hockeyapp --token [YOUR_API_TOKEN] --input [YOUR_BINARIES_PATH]


To get a list of available options, execute:

    $ tfexporter hockeyapp --help

### DeployGate integration

Since version 0.2.2 TestFlight exporter supports the upload of your downloaded binaries on DeployGate platform.
Execute the following command in your terminal:

    $ tfexporter deploygate --username [YOUR_USERNAME] --token [YOUR_API_TOKEN] --input [YOUR_BINARIES_PATH]


To get a list of available options, execute:

    $ tfexporter deploygate --help

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

## Credits

TestFlight exporter is created by me, [Fabio Milano](https://twitter.com/fabiom_milano). I am an iOS Engineer at [Touchwonders](http://www.touchwonders.com/),
a mobile app agency based in the Netherlands .

At Touchwonders, we have been using TestFlightapp.com for the past few years to share the latest builds with our clients and to distribute Betas for [Highstreetapp](http://www.highstreetapp.com).

My goal was to create a script to export your app binaries in a fast and simple way, I hope you like it.

We'd like to thank the TestFlight team for their efforts – we were happy users of their services.
TestFlight will shutdown next week but I will maintain it until the shutdown.

Follow us on twitter @touchwonders and let me know what you think!

## License

TestFlight exporter is available under the MIT license. See the LICENSE file for more info.
