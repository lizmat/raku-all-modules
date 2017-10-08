#!/usr/bin/env perl6

unit module Net::ZMQ::Version;

use v6;
use NativeCall;



use Net::ZMQ::V4::Constants;
use Net::ZMQ::V4::LowLevel;


constant ZMQ_VERSION  is export =
	10000 * ZMQ_VERSION_MAJOR
	+ 100 * ZMQ_VERSION_MINOR
	+  ZMQ_VERSION_PATCH;

my $verbose = True;

my $zmq_major;
my $zmq_version;


sub version_major() is export {return $zmq_major };


sub version() is export  {
    return $zmq_version if $zmq_version;

    my int32 ($major, $minor, $patch);
    zmq_version($major, $minor, $patch);
    my ($mj, $mn, $pt ) = ($major, $minor, $patch);
    $zmq_version = ( $mj, $mn, $pt ).join('.');
    $zmq_major = $mj;
    say "Installed ZeroMQ Library $mj.$mn.$pt" if $verbose;
    return $zmq_version;
}

INIT {
    version();

    if ZMQ_VERSION_MAJOR != $zmq_major {
			say "Module compiled for ZMQ version " ~ ZMQ_VERSION_MAJOR ~ ". But version $zmq_major found!";
    }
    given $zmq_major {
        when 4 {
				}
    }
    say "Tested Low Level Functions :\n\t" ~ ZMQ_LOW_LEVEL_FUNCTIONS_TESTED if $verbose;
}
