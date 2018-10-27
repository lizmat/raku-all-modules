# Perl6 Telegram Bot Library

This library offers *some* Perl6 objects and routines that correspond to Telegram's bot API in a reactive form.

```perl6
use Telegram;

my $bot = Telegram::Bot.new('<Your bot token>');
$bot.start(interval => 1); # Starts scanning for updates; defaults to every 2 seconds

my $msgTap = $bot.messagesTap; # A tap for updates

react {
  whenever $msgTap -> $msg {
    say "{$msg.sender.username}: {$msg.text} in {$msg.chat.id}";
  }
  whenever signal(SIGINT) {
    $bot.stop;
    exit;
  }
}
```

## Installation
`zef install telegram`
