
use lib 'lib';
use HTTP::Server;
use Test;

plan 2;

ok !so try {
  CATCH { default { False; } };
  my $r = (class {

  }).new;
  $r does HTTP::Server;
  $r.middleware;
  True;
}, 'Class must implement methods from role';

ok try {
  CATCH { default { .say; False; } };
  my $r = (class :: does HTTP::Server {
    method middleware { qw<hi>; }
    method after      { qw<hi>; }
    method handler    { qw<hi>; }
    method listen     { qw<hi>; }
  }).new;
  True;
}, 'Can instantiate with all methods defined';
