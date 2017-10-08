#!/usr/local/bin/perl6

use v6;

use lib 'lib';

use Linux::Process::SignalInfo;

#| Show process signal information
sub MAIN(Int :p(:$process-id)!) {
    my $signal_info = Linux::Process::SignalInfo.new(pid => $process-id);
    $signal_info.read;
    $signal_info.parse;
    $signal_info.pprint;
}
