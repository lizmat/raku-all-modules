#!/usr/bin/env perl6

unit module Net::ZMQ::Error;
use v6;

use Net::ZMQ::V4::LowLevel;

class ZMQError is Exception is export {
    has Int $.errno;
    has Str $.description;

    submethod BUILD() {
    	$!errno = zmq_errno();
	    $!description = zmq_strerror($!errno);
    }

    method message() {
	     say "reporting ZMQ error ( $.errno ): $.description";
       return "ZMQ error ( $.errno ): $.description";
    }
}

sub get-error() is export {
    return ZMQError.new();
}


sub throw-error() is export {
    get-error().throw();
}
