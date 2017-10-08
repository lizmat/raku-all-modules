use v6;
use Test;

plan 6;

use Imlib2;

my $im = Imlib2.new();

my $color_modifier = $im.create_color_modifier();
isa_ok $color_modifier, Imlib2::ColorModifier;
ok $color_modifier, 'create_color_modifier';

lives_ok { $color_modifier.context_set(); }, 'context_set color_modifier';

my $get_color_modifier = $im.context_get_color_modifier();
isa_ok $get_color_modifier, Imlib2::ColorModifier;
ok $get_color_modifier, 'context_get_color_modifier';

lives_ok { $im.free_color_modifier(); }, 'free_color_modifier';

done;
