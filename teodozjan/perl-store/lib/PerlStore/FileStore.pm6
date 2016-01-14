use v6;
use MONKEY-SEE-NO-EVAL;

unit role FileStore;

sub serialize($what) returns Str {
    $what.perl
}

sub deserialize(Str $sth){
    EVAL($sth)
}

sub to_file($path, $what) is export {
    given open($path, :w) {
	.say(serialize($what));
	.close
    }
}

sub from_file($path) is export {
    if $path.IO ~~ :e {
	return deserialize(slurp $path)
    } else {
	warn "Cannot read $path";
        False;
}
}

method to_file($path) {
    &to_file($path, self);
}

method from_file($path) {
    &from_file($path);
}
