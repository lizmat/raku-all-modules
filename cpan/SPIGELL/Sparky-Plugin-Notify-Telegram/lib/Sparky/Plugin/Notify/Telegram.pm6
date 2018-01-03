use v6;
use TelegramBot;

unit module Sparky::Plugin::Notify::Telegram;

our sub run ( %ctx, %parameters ) {

  my $build-id = %ctx<build-id> || "unknown";
  my $project = %ctx<project>;
  my $build-state = %ctx<build-state>;

  say "trigger notification. $project\@$build-id, state: $build-state";

  my $token = %parameters<token>;
  my $message = %parameters<message>;
  my $chat_id = %parameters<id>;

  my $bot = Telegram::Bot.new($token);

  if %parameters<offline> {
    say "don't send notification, we are in offline mode ...";
  } else {

  $bot.send-message({ chat-id => $chat_id, text => $message });

  }
}
