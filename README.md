# Rairtame

Rairtame is a Command-Line Interface and Ruby wrapper around the `airtame-streamer` JSON-RPC API.

It allows to easily control the `airtame-streamer` daemon, which is in charge of capturing and streaming video to an (http://airtame.com)[AIRTAME dongle].

**Make sure the `airtame-streamer` is running when using `rairtame`**

## Installation

Rairtame is distributed as a Ruby gem. It can be installed by running:

    $ gem install rairtame

## CLI Usage

The Rairtame Command-Line interface is accessed through the

    $ rairtame command [arguments]

command.

Remember to run `rairtame init` to init the streamer before connecting anywhere.

You can see all the options running `rairtame -h`.

## Ruby library usage

You can also easily integrate your own code against this library. For example:

```ruby
require 'rairtame'
client = Rairtame::Client.new()
client.init_streamer()
client.connect("myairtame")
client.quality = 5
client.buffer = 5000
client.disconnect()
client.close_streamer()
```

## Limitations

Rairtame does not yet implement the SSDP protocol (which allows autodiscovery of the streamer) nor performs any registration with the `airtame-streamer` (for example to receive notifications).

Particularly, I don't see many uses for these features at this point, and the official (https://github.com/airtame/airtame-cli)[Airtame CLI] supports them.

## Contributing

Please do!
