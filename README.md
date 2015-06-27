# Rairtame

[![Gem Version](https://badge.fury.io/rb/rairtame.svg)](http://badge.fury.io/rb/rairtame)

Rairtame is a library and CLI utility to interact with the `airtame-streamer` JSON-RPC API.

It allows to easily control the `airtame-streamer` daemon, which is in charge of capturing and streaming video to an [AIRTAME dongle](http://airtame.com).

**Make sure the `airtame-streamer` is running when using `rairtame`**.

## Installation

Rairtame is distributed as a Ruby gem. It can be installed by running:

    $ gem install rairtame

## CLI Usage

The Rairtame Command-Line interface is accessed through the

    $ rairtame command [arguments]

command. Supported commands:

```
COMMANDS
    audio      - Enable or disable audio
    buffer     - Set streaming buffer length in ms
    close      - Close the streamer
    connect    - Connect to Airtame dongle
    disconnect - Disconnect from the Airtame dongle
    fluent     - Enable or disable fluent video playback
    fps        - Set streaming fps [1-60]
    help       - Shows a list of commands or help for one command
    init       - Init the streamer
    mode       - Set streaming mode
    quality    - Set streaming quality [1-5]
    reliable   - Enable or disable reliability
    resolution - Set streaming resolution
    status     - Show streamer's status
    video      - Enable or disable video
```

Remember to run `rairtame init` to init the streamer before connecting anywhere.

You can see all the options running `rairtame -h`.

## Ruby library usage

You can also easily integrate your own code against this library. For example:

```ruby
require 'rairtame'
client = Rairtame::Client.new()
client.init_streamer()
client.connect("myairtame") # hostname or ip
client.quality = 5
client.buffer = 5000
client.disconnect()
client.close_streamer()
```

## Limitations

Rairtame does not yet implement the SSDP protocol (which allows autodiscovery of the streamer) nor performs any registration with the `airtame-streamer` (for example to receive notifications).

Particularly, I don't see many uses for these features at this point, and the official [Airtame CLI](https://github.com/airtame/airtame-cli) supports them.

## Contributing

Please do!
