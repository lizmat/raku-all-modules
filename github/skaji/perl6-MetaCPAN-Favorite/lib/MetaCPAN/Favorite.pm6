use v6;
unit class MetaCPAN::Favorite;
use HTTP::Tinyish;
use JSON::Tiny;

class SilentHTTP is HTTP::Tinyish {
    sub info($msg) { note $msg }
    method new(*%opt) {
        %opt<async> = True;
        %opt<timeout> = 10;
        callwith(|%opt);
    }
    method get(|) {
        callsame.then: sub ($p) {
            if $p.status ~~ Kept {
                my $res = $p.result;
                if $res<success> {
                    return $res<content>;
                } else {
                    info("Failed to get {$res<url>}: {$res<status>} {$res<reason>}");
                }
            } else {
                info("Promise broken: {$p.cause}");
            }
            return;
        };
    }
}

has $.favorite-url = "http://api.metacpan.org/v0/favorite/_search/?fields=user,distribution,date&sort=date:desc&size=10";
has $.user-url = "http://api.metacpan.org/v0/author/_search/?fields=_id&q=user:";
has $.distribution-url = "https://metacpan.org/release/";
has $.cache;
has %.seen;

method Supply {
    Supply.on-demand: -> $s {
        self.load;
        my @fav = await self.get-new-favorite;
        await @fav.map: -> $f {
            self.get-user-name($f<user>).then: -> $p {
                my $user = $p.result;
                $s.emit: %(
                    name => $f<name>,
                    date => $f<date>,
                    user => $user,
                    url => $.distribution-url ~ $f<name>,
                );
            };
        };
        self.save;
        $s.done;
    };
}

method get-new-favorite {
    SilentHTTP.new.get($.favorite-url).then: sub ($p) {
        my $res = $p.result;
        return Empty unless $res;
        my @fav = from-json($res)<hits><hits>.map({ $_<fields> }).map: -> $f {
            %(name => $f<distribution>, date => $f<date>, user => $f<user>);
        };
        my @new = @fav.grep({ not %.seen{ $_<date> ~ " " ~ $_<name> } });
        for @fav {
            %.seen{ $_<date> ~ " " ~ $_<name> } = True;
        }
        @new.reverse;
    };
}

method get-user-name($user is copy) {
    $user = qq{"$user"};
    SilentHTTP.new.get($.user-url ~ $user).then: sub ($p) {
        my $res = $p.result;
        return unless $res;
        my $hit = from-json($res)<hits><hits>;
        if $hit ~~ Positional and @($hit).elems > 0 {
            return $hit[0]<_id>;
        } else {
            return;
        }
    };
}

method load() {
    my $fh = try $.cache.IO.open(:r);
    return unless $fh;
    LEAVE $fh.close if $fh;
    for $fh.lines(:chomp) -> $line {
        my ($date, $name) = $line.split(" ", 2);
        %.seen{ "$date $name" } = True;
    }
}

method save() {
    my %new;
    {
        my $fh = "{$.cache}.tmp".IO.open(:w);
        LEAVE $fh.close if $fh;

        my $max = 30;
        my $i = 0;
        for %.seen.keys.sort({ $^b cmp $^a }) -> $key {
            $i++;
            $fh.print("$key\n");
            %new{$key} = True;
            last if $i > $max;
        }
    }
    "{$.cache}.tmp".IO.rename($.cache);
    %.seen = %new;
}

=begin pod

=head1 NAME

MetaCPAN::Favorite - consume MetaCPAN recent favorite

=head1 SYNOPSIS

  use MetaCPAN::Favorite;

  my $metacpan = MetaCPAN::Favorite.new(cache => "./cache.txt");
  my $favorite = Supply.interval(60).map({ $metacpan.Supply }).flat;

  react {
    whenever $favorite -> %fav {
      my $name = %fav<name>; # Plack
      my $user = %fav<user>; # SKAJI (the user who favorites Plack, can be undef)
      my $date = %fav<date>; # 2016-08-05T07:49:15.000Z
      my $url  = %fav<url>;  # https://metacpan.org/release/Plack

      $user //= "anonymous";
      tweet("$name++ by $user, $url"); # or, whatever you want
    };
  };

=head1 DESCRIPTION

MetaCPAN::Favorite helps you consume MetaCPAN recent favorite page.

https://metacpan.org/favorite/recent

=head1 MOTIVATION

I want to learn how to do concurrency and asynchronous programming in Perl6.
More precisely, I want to learn how to use
Supply, Channel, Promise, react, whenever, supply.... in Perl6.

Your advice will be highly appreciated.

=head1 AUTHOR

Shoichi Kaji <skaji@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
