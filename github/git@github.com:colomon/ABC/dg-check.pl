use v6;

use lib 'lib';
use ABC;

my @matches = $*IN.slurp.comb(m/ <ABC::tune> /, :match);

my %dg_notes = {
    'g' => 1,
    'a' => 1,
    'b' => 1,
    'c' => 1,
    'd' => 1,
    'e' => 1,
    '^f' => 1
}

for @matches {
    my %header = header_hash(.<ABC::tune><header>);
    say %header<T> ~ ":";

    my @notes = gather for .<ABC::tune><music><line_of_music> -> $line
    {
        for $line<bar> -> $bar
        {
            for $bar<element>
            {
                when .<broken_rhythm> { take .<broken_rhythm><stem>[0]<note>; take .<broken_rhythm><stem>[1]<note>; }
                when .<stem>          { take .<stem><note>; }
            }
        }
    }

    my %key_signature = key_signature(%header<K>);

    my @trouble = @notes.map({apply_key_signature(%key_signature, .<pitch>)}).grep({!%dg_notes{lc($_)}:exists});
    say @trouble.perl;
}
