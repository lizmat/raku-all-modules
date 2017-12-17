#!/usr/bin/env perl6

use v6;

use lib '/home/docker/workspace/perl6-jupyter/lib';

use Net::ZMQ::Context:auth('github:gabrielash');
use Net::ZMQ::Socket:auth('github:gabrielash');
use Net::ZMQ::Message:auth('github:gabrielash');
use Net::ZMQ::Poll:auth('github:gabrielash');
use Net::ZMQ::EchoServer:auth('github:gabrielash');

use Net::Jupyter::Common;
use Net::Jupyter::Messages;
use Net::Jupyter::Messenger;
use Net::Jupyter::Executer;

use Log::ZMQ::Logger;

use JSON::Tiny;

my $VERSION := '0.1.3';
my $AUTHOR  := 'Gabriel Ash';
my $LICENSE := 'Artistic-2.0';
my $SOURCE  :=  'https://github.com/gabrielash/p6-net-jupyter';

my Str $err-str := 'Perl6 Jupyter kernel:';

constant POLL_DELAY = 10;

my Logger $LOG = Logging::instance('jupyter', :format(:zmq)).logger;
$LOG.log("$err-str init: $VERSION : $AUTHOR");
say "$err-str init: $VERSION : $AUTHOR";

my Context $ctx;
my EchoServer $heartbeat;
my Socket $ctrl;
my Socket $shell;
my Socket $stdin;
my Socket $iopub;


my Str $uri-prefix;
my Str $ctrl-uri;
my Str $shell-uri;
my Str $stdin-uri;
my Str $iopub-uri;
my Str $heartbeat-uri;

my Str $key;
my Str $scheme;
my Str $engine-id;

sub close-all {
  $LOG.log("$err-str: Exiting now");
  sleep 1;
  $heartbeat.shutdown;
  sleep 1;
  $iopub.unbind.close;
  $stdin.unbind.close;
  $ctrl.unbind.close;
  $shell.unbind.close;
  $LOG.log("$err-str: Adieu");
}


sub shell-handler(MsgRecv $m) {
  $LOG.log("$err-str: SHELL");
  my Messenger $recv .= new(:msg($m), :key($key), :session-key($engine-id), :logger($LOG));

  my $parent-header = $recv.header();
  my $metadata = '{}';
  my @identities = $recv.identities();

  given $recv.type() {
    when 'kernel_info_request' {
        my $content = kernel_info-reply-content($VERSION);
        $recv.send($shell, 'kernel_info_reply', $content, :$parent-header, :@identities);
        True;
    }
    when 'execute_request' {
      my $code = $recv.code;
      my $store-history = $recv.store-history;
      my $silent = $recv.silent;
      $store-history = False if $silent;
      my %expressions = $recv.expressions;

      # say "CODE: $code"; say "$silent : $store-history"; say 'EXP'~ %expressions.perl;
      my Executer $exec .= new(:$code, :$silent, :$store-history, :%expressions);

      with $exec {
            my @iopub-identities = 'execute_request';
            # we are working
            $recv.send($iopub, 'status', status-content('busy')
                        , :$parent-header, :identities( ['status']  ));
            # publish input
            $recv.send($iopub, 'execute_input', execute_input-content(.count, $code)
                        , :$parent-header, :identities(  ['execute_input']  ));

            if (!$silent)  {
              # publish errors ( stderr)
                $recv.send($iopub, 'stream', stream-content('stderr', .err )
                          , :$parent-header, :identities(  ['stream']  ))
                    if .err.defined;

                # publish side-effects (stdout)
                my $type = get-mime-type(.out);
                if is-display($type) {
                  $recv.send($iopub, 'display_data', display-data( [ .out ] )
                        , :$parent-header, :identities( ['display_data'] ));
                } else {
                  $recv.send($iopub, 'stream', stream-content('stdout', .out)
                        , :$parent-header, :identities( ['stream'] ));
                }
                # publish returned value
                $recv.send($iopub, 'execute_result', execute_result-content(.count, .value, .metadata)
                      , :$parent-header, :identities( ['execute_result'] ));
            }
            # say we are done
            $recv.send($iopub, 'status', status-content('idle')
                  , :$parent-header, :identities( ['status'] ));

            # reply
            $recv.send($shell, 'execute_reply'
                , execute_reply-content(.count, .err, .user-expressions, .payload )
                , :$parent-header
                , :metadata(execute_reply_metadata($engine-id, 'ok', .dependencies-met ))
                , :@identities);

            True;
        }#with exec
    }#when

    when 'shutdown_request' {
        $leaving = True;
        my $restart = $recv.content-value( 'restart' );
        $recv.send($shell, 'shutdown_reply'
            , shutdown_reply-content( $restart )
            , :$parent-header
            , $metadata
            , :@identities);
        Any;
    }#when

    default {
      $LOG.log("SHELL: message type $_ NOT IMPLEMENTED");
      True;
    }#default

  }#giveb
}#shell-handler

sub ctrl-handler(MsgRecv $m) {
  $LOG.log("$err-str: CTRL");
  my Messenger $recv .= new(:msg($m), :key($key), :session-key($engine-id), :logger($LOG));

  my $parent-header = $recv.header();
  my $metadata = '{}';
  my @identities = $recv.identities();

  given $recv.type() {
    when 'shutdown_request' {
        my $restart = $recv.content-value( 'restart' );
        $restart = $restart[0] if $restart ~~ List;  #WHY?
        $LOG.log("$err-str: $restart.perl"); die $restart.gist unless $restart ~~ Bool;
        $recv.send($shell, 'shutdown_reply'
            , shutdown_reply-content( $restart )
            , :$parent-header
            , :$metadata
            , :@identities);
        Any;
    }#when
    default {
      $LOG.log("CTRL: message type $_ NOT IMPLEMENTED");
      True;
    }#default
  }
}# ctrl-handler

sub MAIN( $connection-file ) {

  $engine-id = uuid();

  die "$err-str Connection file not found" unless $connection-file.IO.e;
  die "$err-str Connection file is not a file" unless $connection-file.IO.f;
  die "$err-str Connection file is not readable" unless $connection-file.IO.r;

  my $con = slurp $connection-file;
  my %conn = from-json($con);
  for %conn.kv -> $k, $v {say "$k = $v" };

  $uri-prefix = %conn{'transport'} ~ '://' ~ %conn{'ip'} ~ ':';
  $ctrl-uri = $uri-prefix ~ %conn{'control_port'};
  $shell-uri = $uri-prefix ~ %conn{'shell_port'};
  $heartbeat-uri = $uri-prefix ~ %conn{'hb_port'};
  $stdin-uri = $uri-prefix ~ %conn{'stdin_port'};
  $iopub-uri = $uri-prefix ~ %conn{'iopub_port'};

  $ctx .= new;
  $ctrl  .= new( $ctx, :router );
  $shell .= new( $ctx, :router );
  $stdin .= new( $ctx, :router );
  $iopub .= new( $ctx, :publisher );

  $iopub.bind( $iopub-uri );
  $ctrl.bind( $ctrl-uri );
  $shell.bind( $shell-uri );
  $stdin.bind( $stdin-uri );

  $key = %conn< key >;
  $key = Str if $key eq '';
  if !$key.defined {
    $LOG.log("NO Security Token! Verification disabled.");
    say "Perl6 Kernel: NO Security Token! Verification disabled."
  }

  $scheme = %conn< signature_scheme >;
  die "hmac-sha256 is the only implemented signature scheme "
    unless $scheme eq 'hmac-sha256';

  my Poll $poller = PollBuilder.new\
      .add( MsgRecvPollHandler.new($ctrl, &ctrl-handler ))\
      .add( MsgRecvPollHandler.new($shell, &shell-handler ))\
#      .add( MsgRecvPollHandler.new($stdin, &stdin-handler ))\
      .delay( POLL_DELAY)\
      .finalize;

  $LOG.log("$err-str polling set");
  $heartbeat = EchoServer.new( :uri($heartbeat-uri) ).detach;
  $LOG.log("$err-str heartbeat started $heartbeat-uri");

  loop {
      #die "POLL SETTING $shell-uri";
      last if 0 < $poller.poll().grep( ! *.defined );
  }


  close-all;
}


sub USAGE {

  say qq:to/END/;

    Perl6 Jupyter Kernel
    Usage
          perl6 scriptname connection-file

    Version   $VERSION
    Author    $AUTHOR
    License   $LICENSE
    sources   $SOURCE

    END
    #:

}

=finish

example connection file
{
  "control_port": 50160,
  "shell_port": 57503,
  "transport": "tcp",
  "signature_scheme": "hmac-sha256",
  "stdin_port": 52597,
  "hb_port": 42540,
  "ip": "127.0.0.1",
  "iopub_port": 40885,
  "key": "a0436f6c-1916-498b-8eb9-e81ab9368e84"
}
