use v6.c;

unit module Terminal::Spinners:ver<0.0.3>:auth<github:ryn1x>;

class Spinner is export {
    has $.type = 'classic';
    has $.speed = 0.08;
    has $!index = 0;
    has @!spin = <| / - \\>;
    has @!bounce = ('[=   ]', '[==  ]', '[=== ]', '[ ===]', '[  ==]',
                    '[   =]', '[    ]', '[   =]', '[  ==]', '[ ===]',
                    '[====]', '[=== ]', '[==  ]', '[=   ]', '[    ]');
    has %!types = classic => @!spin,
                  bounce => @!bounce;

    method next() {
        # prints the next frame of the spinner animation
        # prints over the previous frame
        print "\b" x %!types{$.type}[0].chars;
        print %!types{$.type}[$!index];
        sleep $!speed;
        $!index = ($!index + 1) % %!types{$.type}.elems;
    }
}

class Bar is export {
    has $.type = 'hash';
    has $.length = 80;
    has @!hash = <[ # . ]>;
    has @!equals = <<[ = ' ' ]>>;
    has %!types = hash => @!hash,
                  equals => @!equals;

    method show(Num $percent is copy) {
        # takes a floating point number and shows a progress bar for that percent
        # prints over the previous progress bar
        $percent = 0e0 if $percent < 0e0;
        $percent = 100e0 if $percent > 100e0;
        my $percent-string = sprintf '%.2f', $percent;
        my $bar-length = $percent.Int * ($!length - 9) div 100;
        my $blank-space = ($!length - 9) - $bar-length;
        print "\b" x $.length;
        print %!types{$!type}[0] ~
              %!types{$!type}[1] x $bar-length ~
              %!types{$!type}[2] x $blank-space ~
              %!types{$!type}[3] ~
              $percent-string ~
              '%';
    }
}
