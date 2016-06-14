use v6.c;
use Test;
use Config::DataLang::Refine;

#-------------------------------------------------------------------------------
# First config
spurt( '.myCfg.cfg', Q:to/EOOPT/);
  {
    "app": {
      "workdir": "/var/tmp",
      "text": "abc def xyz",

      "p1": {
        "workdir": "/tmp",
        "host": "example.com"
      },

      "p2": {
        "workdir": "~/p2",
        "tunnel": true,
        "vision": false
      }
    },

    "p2": {
      "workdir": "~/p2",
      "times": [10,11,12],
      "tunnel": true
    }
  }

  EOOPT


# Second config
spurt( 'myCfg.cfg', Q:to/EOOPT/);
  {
    "app": {
      "port": 2345,
      "p": true,
      "q": true,
      "test": false,

      "p1": {
        "workdir": "/tmp"
      },

      "p2": {
        "workdir": "~/p2",
        "tunnel": false,
        "vision": true
      }
    },

    "p2": {
      "per5lib": [ "lib", "."],

      "env": {
        "PATH": [ "/usr/bin", "/bin", "."],
        "perl6lib": [ "lib", "."],
        "perl5lib": false
      }
    },

    "p3": {
      "name": "key=a string! &@data"
    }
  }

  EOOPT

#-------------------------------------------------------------------------------
subtest {

  try {
    my Config::DataLang::Refine $c .= new;

    CATCH {
      default {
        like .message, / :s Config file .* not found/, .message;
      }
    }
  }

  my Config::DataLang::Refine $c .= new(
    :config-name<myCfg.cfg>,
    :data-module<JSON::Fast>
  );
  ok $c.config<app><workdir>:!exists, 'no workdir';
  is $c.config<app><p1><workdir>, '/tmp', "workdir p1 $c.config()<app><p1><workdir>";
  ok $c.config<app><p1><host>:!exists, 'no host';
  is $c.config<app><p2><workdir>, '~/p2', "workdir p2 $c.config()<app><p2><workdir>";

  $c .= new( :config-name<myCfg.cfg>, :merge, :data-module<JSON::Fast>);
  is $c.config<app><workdir>, '/var/tmp', "workdir app $c.config()<app><workdir>";
  is $c.config<app><p1><workdir>, '/tmp', "workdir p1 $c.config()<app><p1><workdir>";
  is $c.config<app><p1><host>, 'example.com', "host p1 $c.config()<app><p1><host>";
  is $c.config<p2><workdir>, '~/p2', "workdir p2 $c.config()<p2><workdir>";
  is-deeply $c.config<p2><times>, [10,11,12], "times p2 $c.config()<p2><times>";
  nok $c.config<app><p2><tunnel>, 'tunnel p2 false';
  ok $c.config<app><p2><vision>, 'vision p2 true';

}, 'build tests';

#-------------------------------------------------------------------------------
subtest {

  my Config::DataLang::Refine $c .= new(
    :config-name<myCfg.cfg>,
    :data-module<JSON::Fast>
  );
  my Hash $o = $c.refine(<app>);
  ok $o<workdir>:!exists, "app has no workdir";
  is $o<port>, 2345, "port app $o<port>";

  $o = $c.refine(<app p1>);
  is $o<workdir>, '/tmp', "workdir p1 is $o<workdir>";
  is $o<port>, 2345, "port p1 $o<port>";


  $c .= new( :config-name<myCfg.cfg>, :merge, :data-module<JSON::Fast>);
  $o = $c.refine(<app>);
  is $o<workdir>, '/var/tmp', "workdir app $o<workdir>";
  is $o<port>, 2345, "port app $o<port>";

  $o = $c.refine(<app p1>);
  is $o<host>, 'example.com', "host p1 is $o<host>";
  is $o<port>, 2345, "port p1 $o<port>";

}, 'refine tests';

#-------------------------------------------------------------------------------
subtest {

  my Config::DataLang::Refine $c .= new(
    :config-name<myCfg.cfg>,
    :data-module<JSON::Fast>
  );
  my Hash $o = $c.refine( <p2 env>, :filter);
  ok $o<perl5lib>:!exists, 'no perl5 lib';
  is-deeply $o<perl6lib>, [ 'lib', '.'], "perl6lib $o<perl6lib>";

}, 'refine filter hash tests';

#-------------------------------------------------------------------------------
subtest {

  my Config::DataLang::Refine $c .= new(
    :config-name<myCfg.cfg>,
    :data-module<JSON::Fast>
  );
  my Array $o = $c.refine-str( <app>, :filter);
  ok 'port=2345' ~~ any(@$o), 'port in list';
  nok 'workdir=/tmp' ~~ any(@$o), 'workdir not in list';

  $o = $c.refine-str( <app p2>, :filter);
  ok 'port=2345' ~~ any(@$o), 'port in list';
  ok 'workdir=~/p2' ~~ any(@$o), 'workdir in list';
  ok 'vision=True' ~~ any(@$o), 'vision in list';
  nok 'tunnel' ~~ any(@$o), 'tunnel not in list';


  $c .= new( :config-name<myCfg.cfg>, :merge, :data-module<JSON::Fast>);
  $o = $c.refine-str( <app>, :filter);
  ok 'workdir=/var/tmp' ~~ any(@$o), 'app workdir in list';

  $o = $c.refine-str( <app p2>, :filter);
  ok "text='abc def xyz'" ~~ any(@$o), 'p2 text in list';

  $o = $c.refine-str( <p2>, :filter);
  ok 'workdir=~/p2' ~~ any(@$o), 'p2 workdir in list';
  ok 'times=10,11,12' ~~ any(@$o), 'p2 times in list';



  $c .= new( :config-name<myCfg.cfg>, :data-module<JSON::Fast>);
  $o = $c.refine-str( <p3>, :str-mode(C-URI-OPTS-T2));
#say $o[0];
  ok 'name=key%3Da%20string%21%20%26%40data' ~~ any(@$o), 'p3 encoded text in list';

}, 'refine filter string array tests C-URI-OPTS-*';

#-------------------------------------------------------------------------------
subtest {

  my Config::DataLang::Refine $c .= new(
    :config-name<myCfg.cfg>,
    :data-module<JSON::Fast>
  );
  my Array $o = $c.refine-str( <app>, :filter, :str-mode(C-UNIX-OPTS-T1));
  ok '--port=2345' ~~ any(@$o), 'app --port in list';
  nok '--workdir=/tmp' ~~ any(@$o), 'app --workdir /tmp not in list';
  ok '-p' ~~ any(@$o), 'app -p in list';
  ok '-q' ~~ any(@$o), 'app -q in list';

  $o = $c.refine-str( <app p2>, :filter, :str-mode(C-UNIX-OPTS-T1));
  ok '--port=2345' ~~ any(@$o), 'port in list';
  ok '--workdir=~/p2' ~~ any(@$o), 'workdir ~/p2 in list';
  ok '--vision' ~~ any(@$o), '--vision in list';
  nok '--tunnel' ~~ any(@$o), '--tunnel not in list';


  $c .= new( :config-name<myCfg.cfg>, :merge, :data-module<JSON::Fast>);
  $o = $c.refine-str( <app>, :filter, :str-mode(C-UNIX-OPTS-T1));
  ok '--workdir=/var/tmp' ~~ any(@$o), 'app --workdir /var/tmp  in list';

  $o = $c.refine-str( <app p2>, :filter, :str-mode(C-UNIX-OPTS-T1));
  ok "--text='abc def xyz'" ~~ any(@$o), 'p2 --text in list';

  $o = $c.refine-str( <p2>, :filter, :str-mode(C-UNIX-OPTS-T1));
#say $o.perl;
  ok '--workdir=~/p2' ~~ any(@$o), 'p2 --workdir ~/p2 in list';
  ok '--times=10,11,12' ~~ any(@$o), 'p2 --times in list';

}, 'refine filter string array tests C-UNIX-OPTS-T1';

#-------------------------------------------------------------------------------
subtest {

  my Config::DataLang::Refine $c .= new(
    :config-name<myCfg.cfg>,
    :data-module<JSON::Fast>
  );
  my Array $o = $c.refine-str( <app>, :str-mode(C-UNIX-OPTS-T2));
#say $o.perl;
  ok '--port=2345' ~~ any(@$o), 'app --port in list';
  nok '--workdir=/tmp' ~~ any(@$o), 'app --workdir /tmp not in list';
  nok '-p' ~~ any(@$o), 'app -p not in list';
  nok '-q' ~~ any(@$o), 'app -q not in list';
  ok '-pq' ~~ any(@$o), 'app -pq in list';
  ok '--notest' ~~ any(@$o), 'app -notest in list';


  $o = $c.refine-str( <app>, :filter, :str-mode(C-UNIX-OPTS-T2));
  ok '--port=2345' ~~ any(@$o), 'app --port in list';
  nok '--workdir=/tmp' ~~ any(@$o), 'app --workdir /tmp not in list';
  nok '-p' ~~ any(@$o), 'app -p not in list';
  nok '-q' ~~ any(@$o), 'app -q not in list';
  ok '-pq' ~~ any(@$o), 'app -pq in list';

}, 'refine filter string array tests C-UNIX-OPTS-T2';

#-------------------------------------------------------------------------------
# Cleanup
#
unlink 'myCfg.cfg';
unlink '.myCfg.cfg';
done-testing();
exit(0);
