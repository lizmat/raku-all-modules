use v6;
use Test;
plan 5;

use lib 't/lib';

does-load-bar    'use Bar',                                    'a bare use still works';
does-load-bar    'use if; use Bar',                            'a bare use after loading if.pm works';
doesn't-load-bar 'use if; use Bar:if(0)',                      ':if(0) prevents loading a package';
does-load-bar    'use if; use Bar:if($*PERL.version ~~ v6.c)', 'we can use $*PERL.version in :if';
doesn't-load-bar 'use if; use Bar:if($*PERL.version ~~ v7)',   'we can use $*PERL.version in :if';

sub does-load-bar {
    my $*PACKAGE_LOADED = 0;
    EVAL $^code;
    is $*PACKAGE_LOADED, 1, $^comment
}

sub doesn't-load-bar {
    my $*PACKAGE_LOADED = 0;
    EVAL $^code;
    is $*PACKAGE_LOADED, 0, $^comment
}
