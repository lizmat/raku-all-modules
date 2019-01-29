#!/usr/bin/env perl6
use v6.d;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::IP;
use Net::BGP::Time;
use Net::BGP::Validation;

my subset Port of UInt where ^2¹⁶;
my subset Asn  of UInt where ^2¹⁶;

sub MAIN(
    Bool:D               :$passive = False,
    Int:D                :$port = 179,
    Str:D                :$listen-host = '0.0.0.0',
    Int:D                :$my-asn,
    Int                  :$max-log-messages,
    Net::BGP::IP::ipv4:D :$my-bgp-id,
    Int:D                :$batch-size = 32,
    Str                  :$cidr-filter,
    Str                  :$announce,
    Bool:D               :$short-format = False,
    Bool:D               :$af-ipv6 = False,
    Bool:D               :$allow-unknown-peers = False,
    Bool:D               :$send-experimental-path-attribute = False,
    Str:D                :$communities = '',
    Bool:D               :$lint-mode = False,
    *@args is copy
) {
    $*OUT.out-buffer = False;

    my $bgp = Net::BGP.new(
        :$port,
        :$listen-host,
        :$my-asn,
        :identifier(ipv4-to-int($my-bgp-id)),
        :add-unknown-peers($allow-unknown-peers),
    );

    # Add peers
    while @args {
        my $peer-ip  = @args.shift;
        if ! @args.elems { die("Must specify peer ASN after the peer IP"); }
        my $peer-asn = @args.shift;
       
        my $md5; 
        if @args.elems {
            if @args[0] ~~ m/^ '--md5='/ {
                $md5 = S/^ '--md5='// given @args.shift;
                $bgp.add-md5($peer-ip, $md5);
            }
        }

        $bgp.peer-add( :$peer-asn, :$peer-ip, :$passive, :ipv6($af-ipv6) );
    }

    # Build CIDR filter
    my @cidr-str = $cidr-filter.split(',') if $cidr-filter.defined;
    my @cidr-filter = gather {
        for @cidr-str -> $cidr {
            take Net::BGP::CIDR.from-str($cidr);
        }
    }

    # Start the TCP socket
    $bgp.listen();
    lognote("Listening") unless $short-format;
    short-format-output(short-line-header, Array.new) if $short-format;

    my $channel = $bgp.user-channel;

    my $messages-logged = 0;
    my $start = monotonic-whole-seconds;

    react {
        my %sent-connections;

        whenever $channel -> $event is copy {
            my @stack;

            my uint32 $cnt = 0;
            repeat {
                if $event ~~ Net::BGP::Event::BGP-Message {
                    if $event.message ~~ Net::BGP::Message::Open {
                        if %sent-connections{ $event.connection-id }:!exists {

                            my @communities;
                            @communities = $communities.split(',') if $communities ne '';

                            if $send-experimental-path-attribute {
                                my %attr;
                                %attr<path-attribute-code> = 255;
                                %attr<optional>            = 1;
                                %attr<transitive>          = 1;
                                %attr<value>               = buf8.new(0..31);
                                my @attrs;
                                @attrs.push(%attr);
                                announce(
                                    $bgp,
                                    $announce,
                                    $event.connection-id,
                                    :@attrs,
                                    :@communities,
                                    :supports-ipv4($event.message.ipv4-support),
                                    :supports-ipv6($event.message.ipv6-support),
                                );
                            } else {
                                announce(
                                    $bgp,
                                    $announce,
                                    $event.connection-id,
                                    :@communities,
                                    :supports-ipv4($event.message.ipv4-support),
                                    :supports-ipv6($event.message.ipv6-support),
                                );
                            }
                            %sent-connections{ $event.connection-id } = True;
                        }
                    }
                }

                @stack.push: $event;
                if $cnt++ ≤ 8*2*$batch-size {
                    $event = $channel.poll;
                } else {
                    $event = Nil;
                }
            } while $event.defined;

            if @stack.elems == 0 { next; }

            my @str;
            if (@stack.elems > $batch-size) {
                @str = @stack.hyper(
                    :degree(8), :batch((@stack.elems / 8).ceiling)
                ).grep(
                    { is-filter-match($^a, :@cidr-filter, :$lint-mode) }
                ).map({ $^a => $short-format ?? short-lines($^a) !! $^a.Str }).flat;
            } else {
                @str = @stack.map: { $^a.Str }
                @str = @stack.grep(
                    { is-filter-match($^a, :@cidr-filter, :$lint-mode) }
                ).map({ $^a => $short-format ?? short-lines($^a) !! $^a.Str }).flat;
            }

            for @str -> $event {
                my @errors;
                if $event.key ~~ Net::BGP::Event::BGP-Message {
                    @errors = Net::BGP::Validation::errors($event.key.message);
                    if $lint-mode {
                        next unless @errors.elems;  # In lint mode, we only show errors
                    }
                }

                if $short-format {
                    for $event.value -> $entry {
                        short-format-output($entry, @errors);
                    }
                } else {
                    long-format-output($event.value, @errors);
                }

                $messages-logged++;
                if $max-log-messages.defined && ($messages-logged ≥ $max-log-messages) {
                    if ! $short-format {
                        log('*', "RUN TIME: " ~ (monotonic-whole-seconds() - $start) );
                    }
                    exit;
                }
            }
            @str.list.sink;
        }
    }
}

sub announce(
    Net::BGP:D $bgp,
    Str        $announce,
    Int:D      $connection-id,
               :@attrs?,
               :@communities?,
    Bool:D     :$supports-ipv4,
    Bool:D     :$supports-ipv6
    -->Nil
) {
    # Build the announcements
    my @announce-str = $announce.split(',') if $announce.defined;
    for @announce-str -> $info {
        my @parts = $info.split('-');
        die "Announcement must be in format <ip>-<nexthop>" unless @parts.elems == 2;

        # Don't advertise unsupported address families
        if ( $info.contains(':')) and (!$supports-ipv6) { next; }
        if (!$info.contains(':')) and (!$supports-ipv4) { next; }

        $bgp.announce(
            $connection-id,
            [ @parts[0] ],
            @parts[1],
            :@attrs,
            :@communities,
        );
    }
}

multi is-filter-match(
    Net::BGP::Event::BGP-Message:D $event,
    :@cidr-filter,
    :$lint-mode
    -->Bool:D
) {
    if $event.message ~~ Net::BGP::Message::Update {
        if ! @cidr-filter.elems { return True }

        my @nlri = @( $event.message.nlri );
        for @cidr-filter.grep( { $^a.ip-version == 4 } ) -> $cidr {
            if @nlri.first( { $cidr.contains($^a) } ).defined { return True; }
        }

        my @withdrawn = @( $event.message.withdrawn );
        for @cidr-filter.grep( { $^a.ip-version == 4 } ) -> $cidr {
            if @withdrawn.first( { $cidr.contains($^a) } ).defined { return True; }
        }

        my @nlri6 = @( $event.message.nlri6 );
        for @cidr-filter.grep( { $^a.ip-version == 6 } ) -> $cidr {
            if @nlri6.first( { $cidr.contains($^a) } ).defined { return True; }
        }

        my @withdrawn6 = @( $event.message.withdrawn6 );
        for @cidr-filter.grep( { $^a.ip-version == 6 } ) -> $cidr {
            if @withdrawn6.first( { $cidr.contains($^a) } ).defined { return True; }
        }

        return False;
    } else {
        return !$lint-mode;
    }
}
multi is-filter-match($event, :@cidr-filter, :$lint-mode -->Bool:D) { !$lint-mode; }

multi get-str($event, :@cidr-filter -->Str) { $event.Str }

sub logevent(Str:D $event) {
    state $counter = 0;
    lognote("«" ~ $counter++ ~ "» " ~ $event);
}

sub lognote(Str:D $msg) {
    log('N', $msg);
}

sub log(Str:D $type, Str:D $msg) {
    say "{DateTime.now.Str} [$type] $msg";
}

sub long-format-output(Str:D $event is copy, @errors -->Nil) {
    if @errors.elems {
        for @errors -> $err {
            $event ~= "\n      ERROR: {$err.key} ({$err.value})";
        }
    }
    logevent($event);
}

sub short-format-output(Str:D $line, @errors -->Nil) {
    if @errors.elems {
        say $line ~ @errors».key.join(' ');
    } else {
        say $line;
    }
}

multi short-lines(Net::BGP::Event::BGP-Message:D $event -->Array[Str:D]) {
    my Str:D @out;

    my $bgp = $event.message;
    if $bgp ~~ Net::BGP::Message::Open {
        push @out, short-line-open($event.peer, $event.creation-date);
    } elsif $bgp ~~ Net::BGP::Message::Update {
        if $bgp.nlri.elems {
            for @($bgp.nlri) -> $prefix {
                push @out, short-line-announce(
                    $prefix,
                    $event.peer,
                    $bgp,
                    $event.creation-date
                );
            }
        } elsif $bgp.nlri6.elems {
            for @($bgp.nlri6) -> $prefix {
                push @out, short-line-announce6(
                    $prefix,
                    $event.peer,
                    $bgp,
                    $event.creation-date
                );
            }
        } elsif $bgp.withdrawn.elems {
            for @($bgp.withdrawn6) -> $prefix {
                push @out, short-line-withdrawn(
                    $prefix,
                    $event.peer,
                    $event.creation-date
                );
            }
        } elsif $bgp.withdrawn6.elems {
            for @($bgp.withdrawn6) -> $prefix {
                push @out, short-line-withdrawn(
                    $prefix,
                    $event.peer,
                    $event.creation-date,
                );
            }
        }
    } else {
        # Do nothing for other types of messgaes
    }

    return @out;
}

multi short-lines($event -->Array[Str:D]) { return Array[Str:D].new; }

sub short-line-header(-->Str:D) {
    return join("|",
        "Type",
        "Date",
        "Peer",
        "Prefix",
        "Next-Hop",
        "Path",
        "Communities",
        "Errors",
    );
}

sub short-line-announce(
    Net::BGP::CIDR $prefix,
    Str:D $peer,
    Net::BGP::Message::Update $bgp,
    Int:D $message-date,
    -->Str:D
) {
    return join("|",
        "A",
        $message-date,
        $peer,
        $prefix,
        $bgp.next-hop,
        $bgp.path,
        $bgp.community-list.join(" "),
        '',
    );
}

sub short-line-announce6(
    Net::BGP::CIDR $prefix,
    Str:D $peer,
    Net::BGP::Message::Update $bgp,
    Int:D $message-date,
    -->Str:D
) {
    return join("|",
        "A",
        $message-date,
        $peer,
        $prefix,
        $bgp.next-hop6,
        $bgp.path,
        $bgp.community-list.join(" "),
        '',
    );
}

sub short-line-withdrawn(
    Net::BGP::CIDR $prefix,
    Str:D $peer,
    Int:D $message-date,
    -->Str:D
) {
    return join("|",
        "W",
        $message-date,
        $peer,
        $prefix,
        '',
    );
}

sub short-line-open(
    Str:D $peer,
    Int:D $message-date,
    -->Str:D
) {
    return join("|",
        "O",
        $message-date,
        $peer,
        '',
    );
}

