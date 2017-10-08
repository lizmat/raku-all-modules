use v6.c;
unit class App::P6Ghq:ver<0.0.1>;

has $.ghq = "ghq";
has $.zef = "zef";

method run(Str $module, Str :$protocol?) {
    die "Couldn't find zef" if 0 != run $!zef, "--help", :!out, :!err;
    die "Couldn't find ghq" if 0 != run $!ghq, "--version", :!out, :!err;
    my $ok = self.get($module, :$protocol);
    return $ok ?? 0 !! 1;
}

method get(Str $module, Str :$protocol?) {
    note "==> Searching $module by zef...";
    my $zef = run $!zef, "info", "--/cpan", $module, :out, :err;
    LEAVE $zef.out.close;
    LEAVE $zef.err.close;
    if $zef.exitcode != 0 {
        # XXX
        # my $err = $zef.err.slurp.chomp;
        # die "Failed, {$err}";
        note "Not found, $module";
        return;
    }

    my @url = gather for $zef.out.lines -> $line {
        if $line ~~ /^ 'Source-url:' \s+ (\S+) / {
            take $/[0].Str;
        } elsif $line ~~ /^ '#' \s+ 'source:' \s+ (\S+) / {
            take $/[0].Str;
        }
    };

    if +@url == 0 {
        note "Not found, $module";
        return;
    }
    my $url = @url.shift;
    if $protocol {
        $url ~~ s/ ^['git'|'http'|'https'] /$protocol/;
    }
    note "==> Cloning $url by ghq...";
    my $ghq = run $!ghq, "get", $url;
    return $ghq.exitcode == 0;
}


=begin pod

=head1 NAME

App::P6Ghq - get Perl6 module's repository by ghq

=head1 SYNOPSIS

  ❯ p6-ghq App::Mi6
  ==> Searching App::Mi6 by zef...
  ==> Cloning git://github.com/skaji/mi6.git by ghq...
       clone git://github.com/skaji/mi6.git -> /Users/skaji/src/github.com/skaji/mi6
         git clone git://github.com/skaji/mi6.git /Users/skaji/src/github.com/skaji/mi6
  Cloning into '/Users/skaji/src/github.com/skaji/mi6'...
  remote: Counting objects: 497, done.
  remote: Total 497 (delta 0), reused 0 (delta 0), pack-reused 497
  Receiving objects: 100% (497/497), 73.34 KiB | 387.00 KiB/s, done.
  Resolving deltas: 100% (191/191), done.

=head1 DESCRIPTION

App::P6Ghq gets Perl6 module's repository by L<ghq|https://github.com/motemen/ghq>.

=head1 SEE ALSO

https://metacpan.org/pod/App::CPANGhq

=head1 AUTHOR

Shoichi Kaji <skaji@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
