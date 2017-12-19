use v6;

class HTML::Canvas::Tracer {

    has UInt $!indent = 0;

    method callback {
        sub ($op, |c) { self."{$op}"(|c); }
    }

    submethod TWEAK(:$canvas) {
        with $canvas {
            .callback.push: self.callback;
        }
    }

    method FALLBACK($name, *@args, *%opts) {
	$!indent = 0 if $name eq '_start'|'_finish';
	$!indent-- if $name eq 'restore' && $!indent;

	$*ERR.print(('  ' x $!indent) ~ $name ~ '(');

        my Str @pretty = @args.map: *.perl;
        @pretty.push: ':%s(%s)'.sprintf( .key, .value.gist)
            for %opts.pairs.sort; 
	$*ERR.print( @pretty.join: ', ' );

	$*ERR.say(');');

	$!indent++ if $name eq 'save';
        Nil;
    }

}
