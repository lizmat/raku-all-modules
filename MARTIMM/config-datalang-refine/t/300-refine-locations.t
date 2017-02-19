use v6.c;
use Test;
use Config::DataLang::Refine;

#-------------------------------------------------------------------------------
# First config
mkdir 't/cfg-path';
spurt( 't/cfg-path/myCfg.cfg', Q:to/EOOPT/);
  # App control
  [app]
    workdir     = '/var/tmp'
    text        = 'abc def xyz'

  # App control for plugin p1
  [app.p1]
    workdir     = '/tmp'
    host        = 'example.com'

  # Plugin p2
  [p2]
    workdir     = '~/p2'
    times       = [10,11,12]
    tunnel      = true

  [app.p2]
    workdir     = '~/p2'
    tunnel      = true
    vision      = false

  EOOPT


# Second config
spurt( '.myCfg.cfg', Q:to/EOOPT/);
  # App control
  [app]
    port        = 2345

  # App control for plugin p1
  [app.p1]
    workdir     = '/tmp'

  [app.p2]
    workdir     = '~/p2'
    tunnel      = false
    vision      = true

  [p2]
    perl5lib    = [ 'lib', '.']

  [p2.env]
    PATH        = [ '/usr/bin', '/bin', '.']
    perl6lib    = [ 'lib', '.']
    perl5lib    = false

  EOOPT

#-------------------------------------------------------------------------------
subtest {

  # First file to encounter is .myCfg.cfg and stops there because :!merge
  my Config::DataLang::Refine $c .= new(:config-name<t/cfg-path/myCfg.cfg>);
  diag "Configuration: " ~ $c.perl;

  my Hash $o = $c.refine(<app>);
  diag "Refined using <app>: " ~ $c.perl(:h($o));

  ok $o<workdir>:!exists, "app has no workdir";
  is $o<port>, 2345, "port app $o<port>";

  $o = $c.refine(<app p1>);
  diag "Refined using <app p1>: " ~ $c.perl(:h($o));
  is $o<workdir>, '/tmp', "workdir p1 is $o<workdir>";
  is $o<port>, 2345, "port p1 $o<port>";



  # Merge file t/cfg-path/myCfg.cfg followed by file .myCfg.cfg
  $c .= new( :config-name<t/cfg-path/myCfg.cfg>, :merge);
  diag "Configuration: " ~ $c.perl;
  $o = $c.refine(<app>);
  diag "Refined using <app>: " ~ $c.perl(:h($o));

  is $o<workdir>, '/var/tmp', "workdir app $o<workdir>";
  is $o<port>, 2345, "port app $o<port>";

  $o = $c.refine(<app p1>);
  diag "Refined using <app p1>: " ~ $c.perl(:h($o));
  is $o<host>, 'example.com', "host p1 is $o<host>";
  is $o<port>, 2345, "port p1 $o<port>";

}, 'test config-name as relative path';

#-------------------------------------------------------------------------------
subtest {

  my Config::DataLang::Refine $c .= new(
    :config-name<myCfg.cfg>
    :locations(['t/cfg-path'])
  );
  my Hash $o = $c.refine(<app>);
  ok $o<workdir>:!exists, "app has no workdir";
  is $o<port>, 2345, "port app $o<port>";

  $o = $c.refine(<app p1>);
  is $o<workdir>, '/tmp', "workdir p1 is $o<workdir>";
  is $o<port>, 2345, "port p1 $o<port>";


  $c .= new( :config-name<myCfg.cfg>, :merge, :locations(['t/cfg-path']));
  $o = $c.refine(<app>);
  is $o<workdir>, '/var/tmp', "workdir app $o<workdir>";
  is $o<port>, 2345, "port app $o<port>";

  $o = $c.refine(<app p1>);
  is $o<host>, 'example.com', "host p1 is $o<host>";
  is $o<port>, 2345, "port p1 $o<port>";

}, 'test locations';

#-------------------------------------------------------------------------------
subtest {
  try {
    my Config::DataLang::Refine $rc .= new: :locations(['']);

    CATCH {
      when X::Config::DataLang::Refine {
        like .message, / :s Config files derived from '300-refine-locations.toml' /,
             .message;
      }
    }
  }

  try {
    my Config::DataLang::Refine $rc .= new: :locations(['foo/bar/baz']);

    CATCH {
      when X::Config::DataLang::Refine {
        like .message, / :s Config files derived from '300-refine-locations.toml' /,
             .message;
      }
    }
  }
}, 'location with wrong entries';

#-------------------------------------------------------------------------------
# Cleanup
#
unlink '.myCfg.cfg';
unlink 't/cfg-path/myCfg.cfg';
rmdir 't/cfg-path';
done-testing();
exit(0);
