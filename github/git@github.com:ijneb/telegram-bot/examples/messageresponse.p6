use v6;

use lib 'lib';
use Telegram;

my $bot = Telegram::Bot.new('<Your Bot Token>');
$bot.start(interval => 1);

my $tap = $bot.messagesTap;

react {
  whenever $tap -> $msg {
    say "Message: {$msg.text}";
    say "Chat: {$msg.chat.id}";
    say "Sender: {$msg.sender.firstname}";
    say "Date: {$msg.date}";
    say "Image Size: {$msg.image.size}" if ?$msg.image;
  }
  whenever signal(SIGINT) {
    $bot.stop;
    exit;
  }
}
