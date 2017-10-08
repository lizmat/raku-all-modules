use v6;
use Pod::Coverage;
use Test;

unit module Test::Coverage;


#| TAP for Pod::Coverage
sub coverage_ok($metafile) is export {    
    coverage($metafile, False)        
}

#| same as C<coverage_ok>
sub subtest_coverage_ok($metafile, $identity =  "POD coverage") is export {

    subtest {        
        coverage_ok($metafile);     
    }, $identity;
}

#| Subtest version of C<anypod_ok>
sub subtest_anypod_ok($metafile, $identity = "any POD coverage") is export {
    subtest {
       anypod_ok($metafile);     
    }, $identity;
}

#| Checks if provides contain any pod
sub anypod_ok($metafile) {
    coverage($metafile,True);
}

sub coverage($metafile, $anypod) {
    my @cases = Pod::Coverage.use-meta($metafile, $anypod);
    plan @cases.elems;
    for @cases -> $case {
        my $result = $case.are-missing;
        my $what = $case.packageStr ~ " POD coverage";
        if $result {
            $what = $what ~ "\n" ~  $case.get-results.join("\n");
        }
        nok $result, $what;
    }    
}

