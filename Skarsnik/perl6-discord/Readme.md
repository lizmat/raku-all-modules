## Name Discord

Discord is an application that provide text and voice channel. see https://discordapp.com/

There is still a lot of thing to do with this module.
I use the Go library as a reference for the Discord API (https://github.com/bwmarrin/discordgo)
Since the official documentation is quite sparse.

For now it does not support the Websocket API, so you are working with only the REST API

## Example

This is an example from the examples directory

```perl
use Discord;

#This small example allow me to send message to a channel by talking in private with
#This client
my $disc = Discord::Client.new;

#The login method do a lot of work for you, like checking the opened private channel
#And getting the guilds you are part of. It also gather the channels of each guilds.

$disc.login(@*ARGS[0], @*ARGS[1]);

#Every call to get message without argument give the "historic" of the channel
#So we keep the last msg to keep his ID
my @msg = $disc.get-messages($disc.me.private-channels<Skarsnik>);
my $last-msg = @msg.tail[0];

react {
  whenever Supply.interval(5) {
    #We only want new message
    @msg = $disc.get-messages($disc.me.private-channels<Skarsnik>, :after($last-msg.id));
    for @msg -> $msg {
      say $msg.perl;
      $disc.send-message($disc.me<QuillnBlade><qnb-general-sfw>, $msg.content);
      LAST {
        $last-msg = $msg;
      }
    }
  }
}
```