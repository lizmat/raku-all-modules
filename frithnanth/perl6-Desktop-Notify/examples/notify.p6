#!/usr/bin/env perl6

#use lib 'lib';
use Desktop::Notify :constants;

my $notify = Desktop::Notify.new(app-name => 'myapp');
# what about our server?
say 'Server capabilities:';
say $notify.server-caps.perl;
say 'Server info:';
say $notify.server-info.perl;
# create and display notification
my $n = $notify.new-notification(:summary('Attention!'),
                                 :body('What just happened?'),
                                 :icon('stop'),
                                 :timeout(NOTIFY_EXPIRES_NEVER),
                                );
$notify.show($n);
if $notify.error.code != 0 {
  warn 'something bad happened contacting the notify server';
}
sleep 2;
# update notification
$notify.update($n, 'Oh well!', 'Not quite a disaster!', 'stop');
$notify.show($n);
if $notify.error.code != 0 {
  warn 'something bad happened contacting the notify server';
}
sleep 2;
# force closing notification
$notify.close($n);
if $notify.error.code != 0 {
  warn 'something bad happened closing the notification';
}
