use v6;

unit module Sparky::Plugin::Notify::Email;

our sub run ( %ctx, %parameters ) {

  my $build-id = %ctx<build-id> || "unknown";
  my $project = %ctx<project>;
  my $build-state = %ctx<build-state>;

  say "trigger email notification. $project\@$build-id, state: $build-state";

  if %parameters<offline> {
    say "don't send notification, we are in offline mode ...";
  } else {
    say "send email to: %parameters<to>";
    shell("echo 'Sparky $project>\@$build-id build completed. State: $build-state' | mail -s '$project\@$build-id' -t %parameters<to>");
  }
}


