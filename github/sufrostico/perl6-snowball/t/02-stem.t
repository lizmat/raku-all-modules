use v6;

use Test;
use lib 'lib';
use Lingua::Stem::Snowball;

my sub len(Str $str --> int32) {
    Buf.new($str.encode).bytes;
};

# English.
my $stemmer = sb_stemmer_new('english', 'UTF_8');
my $result = sb_stemmer_stem($stemmer, "computer", len("computer"));
ok $result eq "comput", 'English is ok';
sb_stemmer_delete($stemmer);

# Spanish.
$stemmer = sb_stemmer_new('spanish', 'UTF_8');
$result  = sb_stemmer_stem($stemmer, "computación", len("computación"));
ok $result eq "comput", 'Spanish is ok';
sb_stemmer_delete($stemmer);

# Purtuguese.
$stemmer = sb_stemmer_new('portuguese', 'UTF_8');
$result  = sb_stemmer_stem($stemmer, "computador", len("computador"));
ok $result eq "comput", 'Portuguese is ok';
sb_stemmer_delete($stemmer);

# Russian.
$stemmer = sb_stemmer_new('russian', 'UTF_8');
my Str $test_str = "компьютер";
# Since for cyrillic we need just plain characters and EOL.
$result  = sb_stemmer_stem($stemmer, $test_str, $test_str.chars+1);
ok $result eq "комп", 'Russian is ok';
sb_stemmer_delete($stemmer);

done-testing;
