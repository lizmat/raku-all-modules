use v6;
unit role App::AizuOnlineJudge::Submittable;

method get-password() returns Str {
    shell "stty -echo"; my $password = prompt("password: "); "".say; shell "stty echo";
    return $password;
}

method validate-code(Str $code) returns Bool {
    if not $code.IO.f {
	die "ERROR: Couldn't find your code";
    }
    return True;
}

method validate-language(Str $language) returns Bool {
    if <C C++ C++11 C# D Ruby Python Python3 PHP JavaScript Scala Haskell OCaml>.grep(* eq $language) == 0 {
	die "ERROR: $language is not an acceptable language";
    }
    return True;
}

method validate-response($response) returns Bool {
    if not $response.is-success {
	die "ERROR: Failed in sending your code.";
    } elsif $response.content ~~ m/'<succeeded>false</succeeded>'/ {
	if $response.content ~~ m/'<message>' (.+) '</message>'/ {
	    die "ERROR: $0";
	} else {
	    die "ERROR: Failed in sending your code.";
	}
    }
    return True;
}

method wait(Int:D $try-count) {
    $*ERR.say(sprintf("Waiting... (%d seconds)", 4 ** $try-count));
    sleep(4 ** $try-count);
}

method validate-problem-number($problem-number) returns Bool { ... }

method run() { ... }
