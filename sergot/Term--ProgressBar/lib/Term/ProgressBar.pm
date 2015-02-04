use v6;
class Term::ProgressBar;

has Int $.count = 100;
has Str $.name = " ";
has Int $.width = 100;

has Bool $.p;
has Bool $.t;

has $.left = '[';
has $.right = ']';
has $.style = '=';

has Str $!as = "";

has $!step = 0.0;

method update(Int $step) {
    my $start = nqp::time_n();

    my $multi = ($step/($.count/$.width)).floor;
    my $ext = ' ';

    $ext ~= $multi*(100/$.width).round(0.1)~"% " if $.p;
    $ext ~= 'eta '~ (( $start - $!step ) * ( $.count - $step ) ).floor ~ ' s' if $.t && $step > 1;

    $!as = "$.name "~$.left~($.style x $multi)~(' ' x ($.width - $multi))~$.right~" $ext";

    self!clear;
    print $!as;
    say '' if $step == $.count;

    $!step = $start;
}

method message($s) {
    self!clear;
    say $s;
}

method !clear {
    print "\r";
    print ' ' x $!as.chars+1;
    print "\r";
}
