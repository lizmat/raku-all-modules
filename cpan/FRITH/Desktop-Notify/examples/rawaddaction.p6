#!/usr/bin/env perl6

use lib 'lib';
use Desktop::Notify;
use Desktop::Notify :constants;

sub callme($n, $action)
{
  say "Action: $action";
}

notify_init('myapp');
my $n = notify_notification_new('Attention!', 'Problems ahead', 'stop');
notify_notification_add_action($n, 'default', 'Opening...', &callme);
my $err = GError.new;
notify_notification_show($n, $err);
