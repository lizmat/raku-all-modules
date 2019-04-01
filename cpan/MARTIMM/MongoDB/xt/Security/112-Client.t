use v6;
use lib 't'; #, '../Auth-SCRAM/lib'; #, '../BSON/lib';

use Test;
use Test-support;
use MongoDB;
use MongoDB::Client;
use MongoDB::Server;
use MongoDB::Database;
use MongoDB::Collection;
use MongoDB::Server;
use MongoDB::HL::Users;
use BSON::Document;

#-------------------------------------------------------------------------------
drop-send-to('mongodb');
#my $handle = 'MongoDB.mlog'.IO.open( :mode<wo>, :create, :truncate);
#modify-send-to( 'mongodb', :level(MongoDB::MdbLoglevels::Trace), :to($handle));
drop-send-to('screen');
#modify-send-to( 'screen', :level(MongoDB::MdbLoglevels::Info));
info-message("Test start");

my MongoDB::Test-support $ts .= new;
my @serverkeys = $ts.serverkeys.sort;
#my Int $p1 = $ts.server-control.get-port-number(@serverkeys[0]);

my Str $uname = 'Dondersteen';
my Str $pword = 'w40tD8jeDan';
my Str $auname = 'SuperDondersteen';
my Str $apword = 'naDej8Dt04w';

my $p1 = $ts.server-control.get-port-number(@serverkeys[0]);

# Cleanup all before tests
my MongoDB::Client $cl .= new(:uri("mongodb://localhost:$p1"));
my MongoDB::Database $db = $cl.database('test');
$db.run-command: (dropDatabase => 1,);
$db.run-command: (dropAllUsersFromDatabase => 1,);

$db = $cl.database('admin');
$db.run-command: (dropAllUsersFromDatabase => 1,);

my Str $server-version = $cl.server-version("localhost:$p1");
diag "Running tests for server version $server-version";

$cl.cleanup;

#-----------------------------------------------------------------------------
subtest "User and admin account preparation", {
  my MongoDB::Client $client .= new(:uri("mongodb://localhost:$p1"));
  my MongoDB::Database $database = $client.database('test');
  my MongoDB::HL::Users $users .= new(:$database);

  $users.set-pw-security(
    :min-un-length(10),
    :min-pw-length(8),
    :pw_attribs(C-PW-NUMBERS)
  );

  my BSON::Document $doc = $users.create-user(
    $uname, $pword,
    :custom-data(
      license => 'to_kill',
      user-type => 'database-test-admin'
    ),
    :roles( [ ( role => 'readWrite', db => 'test'), ] )
  );

  ok $doc<ok>, "User $uname created";
  trace-message("Result create user $uname: " ~ $doc.perl);


  # Test a user with a wrong role spec
  $doc = $users.create-user(
    'secnd-user', 'secnd-Passwd1',
    :custom-data(
      license => 'to_kill',
      user-type => 'database-test-admin'
    ),
    :roles( [ ( role => 'root', db => 'test'), ] )
  );

  trace-message("Result create user secnd-user: " ~ $doc.perl);

  nok $doc<ok>, "User 'secnd-user' not created";
  is $doc<errmsg>, "No role named root\@test", $doc<errmsg>;
  is $doc<code>, 31, "Errorcode is 31";


  # Admin account is needed to shutdown the server later
  $database = $client.database('admin');
  $users .= new(:$database);
  $doc = $users.create-user(
    $auname, $apword,
    :custom-data( :license<to_kill_all>, :user-type<super-admin>, ),
    :roles( [ <hostManager clusterAdmin> ] )
  );

  trace-message("Result create user $auname: " ~ $doc.perl);

  ok $doc<ok>, "Admin user $auname created";
  $client.cleanup;
}

#-----------------------------------------------------------------------------
restart-to-authenticate;
subtest "mongodb url with username and password SCRAM-SHA-1", {

  diag "Try login user '$uname'";
  my MongoDB::Client $client;
  $client .= new(:uri("mongodb://$uname\:$pword\@localhost:$p1/test"));
  isa-ok $client, MongoDB::Client;

  diag "Try insert on test database";
  my MongoDB::Database $database = $client.database('test');
  my BSON::Document $doc = $database.run-command: (
    insert => 'famous_people',
    documents => [
      BSON::Document.new((
        name => 'Larry',
        surname => 'Wall',
      )),
    ]
  );

  trace-message("Insert with un/pw: " ~ $doc.perl);
  is $doc<ok>, 1, "Result is ok";
  is $doc<n>, 1, "Inserted 1 document";


  # There is only one server
  diag "Try insert on other database";
  $database = $client.database('otherdb');
  $doc = $database.run-command: (
    insert => 'famous_people',
    documents => [
      BSON::Document.new((
        name => 'Larry',
        surname => 'Wall',
      )),
    ]
  );

  if $server-version eq MINVERSION {
    is $doc<ok>, 0, "Insert failure";
    like $doc<errmsg>, /:s not authorized/, $doc<errmsg>;
    is $doc<code>, 13, 'code = 13';
    is $doc<codeName>, 'Unauthorized', 'codeName = Unauthorized';
  }

  elsif $server-version eq MAXVERSION {
    trace-message("Insert with un/pw: " ~ $doc.perl);
    is $doc<ok>, 1, "Result is ok";
    is $doc<n>, 1, "Inserted 1 document";
  }

  # try to shutdown the server
  my BSON::Document $req .= new: ( shutdown => 1, force => True);
  $doc = $database.run-command($req);
  nok $doc<ok>, 'shutdown fails';
  like $doc<errmsg>, /:s against the admin database/, $doc<errmsg>;
  is $doc<code>, 13, 'code = 13';
  is $doc<codeName>, 'Unauthorized', 'codeName = Unauthorized';

  $client.cleanup;

  # this test will throw an exception because user may not authenticate on
  # database admin to do the shutdown.
  try {
    $client .= new(:uri("mongodb://$uname\:$pword\@localhost:$p1/admin"));
    $database = $client.database('admin');
    $req .= new: ( shutdown => 1, force => True);
    $doc = $database.run-command($req);

    CATCH {
      default {
        like .message, /:s Authentication failed/, "Error: " ~ .message;
      }
    }
  }

  $client.cleanup;
}

#-----------------------------------------------------------------------------
# Cleanup
restart-to-normal;

info-message("Test $?FILE end");
done-testing();


#-------------------------------------------------------------------------------
sub restart-to-authenticate( ) {

  ok $ts.server-control.stop-mongod(@serverkeys[0]),
     "Server @serverkeys[0] stopped";
  ok $ts.server-control.start-mongod( @serverkeys[0], 'authenticate'),
     "Server @serverkeys[0] started in authenticate mode";
  sleep 1.0;
};

#-------------------------------------------------------------------------------
sub restart-to-normal( ) {

  ok $ts.server-control.stop-mongod(
     @serverkeys[0], :username($auname), :password($apword)
     ), "Server @serverkeys[0] stopped";
  ok $ts.server-control.start-mongod(@serverkeys[0]),
     "Server @serverkeys[0] started in normal mode";
  sleep 1.0;
}
