use v6;
use Printing::Jdf;

=begin LICENSE

Copyright (c) 2014, carlin <cb@viennan.net>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

=end LICENSE

if not @*ARGS {
    say "Usage:";
    say "$*PROGRAM_NAME example.jdf [--pages]";
    exit(0);
}

my $jdf = Printing::Jdf.new(slurp(@*ARGS[0]));
my $option = @*ARGS[1];

templates();
offsets();
pages();

sub templates {
    say "Templates:";
    for @($jdf.ResourcePool.Layout<Signatures>) -> $signature {
        my $parts = $signature<Template>.split('/');
        my $use = $parts.splice(6);
        printf("%02d: ", $signature<PressRun>);
        say unurl($use.join(' - '));
    }
    blank();
}

sub offsets {
    say "Offsets:";
    my $adj = $jdf.ResourcePool.Layout<PageAdjustments>;
    say "\tX\tY";
    say "Odd:\t" ~ get_adjustments($adj<Odd>);
    say "Even:\t" ~ get_adjustments($adj<Even>);
    blank();
}

sub pages {
    if not $option or $option ne "--pages" {
        say "use --pages to show file information";
    }
    else {
        say "Pages:";
        for $jdf.ResourcePool.Runlist -> $page {
            printf("%02d: ", $page<Page>);
            print $page<Scaling><X> ~ 'x' ~ $page<Scaling><Y> ~ "\t";
            print $page<Offsets><X> ~ '/' ~ $page<Offsets><Y> ~ "\t";
            print "CENTERED\t" if $page<Centered>;
	    print "BLANK\t" if $page<IsBlank>;
            blank();
        }
    }
}

sub get_adjustments($adj) {
    return $adj<X> ~ "\t" ~ $adj<Y>;
}

sub unurl($s) {
    return $s.subst(/ \%(\w\w) /, { chr <0x> ~ $0.Str }, :g);
}

sub blank {
    say '';
}

# vim: ft=perl6
