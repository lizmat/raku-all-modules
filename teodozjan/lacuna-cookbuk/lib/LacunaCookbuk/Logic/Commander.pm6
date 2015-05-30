use v6;


use Form;
use Term::ANSIColor;

use LacunaCookbuk::Logic::BodyBuilder;

unit class LacunaCookbuk::Logic::Commander;
my Str $form =
    color('default') ~ '{<<<<<<<<<<<<<<<<<<} '
    ~ color('red') ~ '{||||||}'
    ~ color('magenta') ~'{||||||}'
    ~ colored('{||||||}','green');

method find_incoming {

    print BOLD, form($form, 'Body', 'Hostile', 'Ally', 'Own'), RESET;
    for (planets, stations) -> Body $body {
	my $status = $body.get_status<body>;	
	next if none($status<num_incoming_enemy>,
		     $status<num_incoming_ally>,
		     $status<num_incoming_own>);

	my $name = $body.name;
	$name = colored($name, 'red') if $status<num_incoming_enemy>;
	print form($form, $body.name,
		   $status<num_incoming_enemy>.subst("0","_"),
		   $status<num_incoming_ally>.subst("0","_"),
		   $status<num_incoming_own>.subst("0","_"));
    }
}

