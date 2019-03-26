use v6;

use MongoDB;
use MongoDB::Server::Socket;
use BSON;
use BSON::Document;
use Semaphore::ReadersWriters;

#-------------------------------------------------------------------------------
unit package MongoDB:auth<github:MARTIMM>;

enum SERVERDATA <<:ServerObj(0) WMRttMs HEARTBEAT>>;

#-------------------------------------------------------------------------------
class Server::Monitor {
  my MongoDB::Server::Monitor $singleton-instance;

  has %!registered-servers;

  # Variables to control infinite monitoring actions
  has Promise $!promise-monitor;

  has Supplier $!monitor-data-supplier;

  has BSON::Document $!monitor-command;
  has BSON::Document $!monitor-result;

  has Semaphore::ReadersWriters $!rw-sem;

  #-----------------------------------------------------------------------------
  # Call before monitor-server to set the $!server object!
  # Inheriting from Supplier prevents use of proper BUILD
  #
  submethod BUILD ( ) {

    $!rw-sem .= new;
    #$!rw-sem.debug = True;
    $!rw-sem.add-mutex-names(
      <m-loop m-servers>, :RWPatternType(C-RW-WRITERPRIO)
    );

    %!registered-servers = %();

    $!monitor-data-supplier .= new;
    $!monitor-command .= new: (isMaster => 1);

    # start the monitor
    debug-message("start monitoring");
    self!start-monitor;
  }

  #-----------------------------------------------------------------------------
  # Prevent calling new(). Must use instance()
  method new ( ) { !!! }

  #-----------------------------------------------------------------------------
  method instance ( --> MongoDB::Server::Monitor ) {

#TODO is this thread safe?
    $singleton-instance //= self.bless;
    $singleton-instance;
  }

  #-----------------------------------------------------------------------------
  method get-supply ( --> Supply ) {

    $!monitor-data-supplier.Supply;
  }

#-----------------------------------------------------------------------------
  method register-server (
    MongoDB::ServerType:D $server,
    Int $heartbeat-frequency-ms = MongoDB::C-HEARTBEATFREQUENCYMS
  ) {

    trace-message(
      "register server $server.name(): $server.server-id(), HB = $heartbeat-frequency-ms"
    );

    $!rw-sem.writer( 'm-servers', {
        if %!registered-servers{$server.server-id}:exists {
          warn-message("server $server.name(): $server.server-id() already registered");
        }

        else {
          trace-message("server $server.name() registered");
          %!registered-servers{$server.server-id} = [
            $server,                  # provided server
            0,                        # init weighted mean rtt in ms
            $heartbeat-frequency-ms   # per server heartbeat
          ];

        } # else
      } # writer block
    ); # writer
  }

  #-----------------------------------------------------------------------------
  method unregister-server ( MongoDB::ServerType:D $server ) {

    trace-message("unregister server $server.name(): $server.server-id()");

    $!rw-sem.writer( 'm-servers', {
        if %!registered-servers{$server.server-id}:exists {
          %!registered-servers{$server.server-id}:delete;
          trace-message("server $server.name() un-registered");
        }

        else {
          warn-message("server $server.name() not registered");
        } # else
      } # writer block
    ); # writer
  }

  #-----------------------------------------------------------------------------
  method !start-monitor ( ) {

    $!promise-monitor .= start( {

        my Duration $rtt;
        my BSON::Document $doc;
        my Int $weighted-mean-rtt-ms;

        # setup a wait array for heartbeat
        my Hash $waits = {};
        my %rs = $!rw-sem.reader(
         'm-servers', sub () { %!registered-servers; }
        );
        for %rs.keys -> Str $server-id {
          $waits{$server-id} = %rs{$server-id}[HEARTBEAT];
        }


        # Do forever once it is started
        loop {

          # need to get %!registered-servers all the time because
          # it changes with (un)registration
          my %rservers = $!rw-sem.reader(
           'm-servers', { %(%!registered-servers.kv) }
          );

          # when all servers are unregistered, sleep a bit and wait for
          # new servers to arrive
          if %rservers.elems == 0 {
            trace-message("no servers to process, sleep a bit");
            sleep 0.5;
            next;
          }

          # setup a wait array and find shortest time to wait
          my $shortest-time = 1_000_000_000;
          my Str $selected-server-id;
          for %rservers.keys -> Str $server-id {
            # new servers do not have their waits entry set yet
            $waits{$server-id} //= %rservers{$server-id}[HEARTBEAT];
            if $waits{$server-id} < $shortest-time {
              $shortest-time = $waits{$server-id};
              $selected-server-id = $server-id;
            }
          }

          trace-message(
            "shortest time: $shortest-time, $selected-server-id, " ~
            %rservers{$selected-server-id}[HEARTBEAT]
          );

          # reset shortest time
          $waits{$selected-server-id} =
            %rservers{$selected-server-id}[HEARTBEAT];

          # adjust remaining entries
          for $waits.keys -> Str $server-id {
            next if $server-id eq $selected-server-id;
            $waits{$server-id} -= $shortest-time;
            $waits{$server-id} = 1 if $waits{$server-id} <= 0;
          }

          trace-message(
            "servers to monitor: " ~ %rservers.values>>.[ServerObj].join(', ')
          );

          my $server = %rservers{$selected-server-id}[ServerObj];

          trace-message("monitoring $selected-server-id is-master requests");
          # get server info
          ( $doc, $rtt) = $server.raw-query(
            'admin.$cmd', $!monitor-command, :!authenticate, :timed-query
          );

          trace-message(
            "monitor is-master request result for $selected-server-id: "
            ~ ($doc//'-').perl
          );

          # when doc is defined, the request ended properly. the ok field
          # in the doc will tell if the operation is succsessful or not
          if $doc.defined {
            # Calculation of Mean Return Trip Time. See also
            # https://github.com/mongodb/specifications/blob/master/source/server-selection/server-selection.rst#calculation-of-average-round-trip-times
            %rservers{$selected-server-id}[WMRttMs] = Duration.new(
              0.2 * $rtt * 1000 + 0.8 * %rservers{$selected-server-id}[WMRttMs]
            );

            # set new value of waiten mean rtt if the server is still registered
            $!rw-sem.writer( 'm-servers', {
                if %!registered-servers{$selected-server-id}:exists {
                  %!registered-servers{$selected-server-id}[WMRttMs] =
                    %rservers{$selected-server-id}[WMRttMs];
                }
              }
            );

            debug-message(
              "weighted mean RTT: %rservers{$selected-server-id}[WMRttMs] (ms) for server $server.name() $server.server-id()"
            );

            $!monitor-data-supplier.emit( {
                :ok, monitor => $doc<documents>[0],
                :server-id($selected-server-id),
                weighted-mean-rtt-ms => %rservers{$selected-server-id}[WMRttMs]
              } # emit data
            ); # emit
#TODO SS-RSPrimary must do periodic no-op
#See https://github.com/mongodb/specifications/blob/master/source/max-staleness/max-staleness.rst#primary-must-write-periodic-no-ops
          }

          # no doc returned, server is in trouble or the connection
          # between it is down.
          else {
            warn-message(
              "no response from server $server.name() $server.server-id()"
            );
            $!monitor-data-supplier.emit( {
                :!ok, reason => 'Undefined document',
                :server-id($selected-server-id)
              } # emit data
            ); # emit
          } # else

          # no need to catch exceptions. all is trapped in Wire. with failures
          # a type object is returned

          trace-message("monitor sleeps for $shortest-time ms");
          # Sleep after all servers are monitored
          sleep $shortest-time / 1000.0;

        } # loop

        "server monitoring stopped";

      } # promise block
    ); # promise
  } # method
}
