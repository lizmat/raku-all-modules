use v6;

=begin pod

=head1 NAME

Chemistry::Elements - do things with the Periodic Table

=head1 SYNOPSIS

=begin code

use Chemistry::Elements;

put "Name for 37 is ", get_name_by_Z( 37 );
put "Name for Rb is ", get_name_by_symbol( 'Rb' );

put "Symbol for 37 is ", get_symbol_by_Z( 37 );
put "Symbol for Rubidium is ", get_symbol_by_name( 'Rubidium' );
put "Symbol for Rubidium is ", get_symbol_by_name( 'Rubidium',  );

put "Atomic number for Rb is ", get_Z_by_symbol( 'Rb' );
put "Atomic number for Rubidium", get_Z_by_name( 'Rubidium' );

# use a German name
put "Atomic number for Rubidium is ", get_symbol_by_name( 'Schwefel', 'de'  );

# Use some types

my ZInt $Z    = 37; # works
my ZInt $BigZ = 138; # nope, because that's not on the chart (yet)
my $minimum = min_Z(); # Always 1, unless something big changes
my $maximum = max_Z(); # More

my ChemicalSymbol $symbol       = 'Rb'; # okay
my ChemicalSymbol $other_symbol = 'X9'; # not okay, not a known symbol

=end code

=head1 DESCRIPTION

=end pod

#|{
Do various things with chemical elements. Convert between symbols, names,
and atomic numbers.
	}
class Chemistry::Elements:auth<github:briandfoy>:ver<0.001003> {
	# names has Pig Latin, English, UK English, German, Russian (so far)
	# there are many more files in lib/Chemistry/Languages and we should
	# use those to build these data structures.
	my @language_column = (
		'pigLatin',
		< en en_US default>,
		'en_UK',
		'de',
		'ru',
		)
			==> map( { state $n = -1; $n++; slip(.flat Z=> (item $n) xx *)  } )
			==> my %language_column;

	my %names = (
		  1 => [ < Ydrogenhai      Hydrogen      Hydrogen      Wasserstoff   Водород > ],
		  2 => [ < Eliumhai        Helium        Helium        Helium        Гелий > ],
		  3 => [ < Ithiumlai       Lithium       Lithium       Lithium       Литий > ],
		  4 => [ < Erylliumbai     Beryllium     Beryllium     Beryllium     Бериллий > ],
		  5 => [ < Oronbai         Boron         Boron         Bor           Бор > ],
		  6 => [ < Arboncai        Carbon        Carbon        Kohlenstoff   Углерод > ],
		  7 => [ < Itrogennai      Nitrogen      Nitrogen      Stickstoff    Азот > ],
		  8 => [ < Xygenoai        Oxygen        Oxygen        Sauerstoff    Кислород > ],
		  9 => [ < Luorinefai      Fluorine      Fluorine      Fluor         Фтор > ],
		 10 => [ < Eonnai          Neon          Neon          Neon          Неон > ],
		 11 => [ < Odiumsai        Sodium        Sodium        Natrium       Натрий > ],
		 12 => [ < Agnesiummai     Magnesium     Magnesium     Magnesium     Магний > ],
		 13 => [ < Luminiumaai     Aluminium     Aluminium     Aluminium     Алюминий > ],
		 14 => [ < Iliconsai       Silicon       Silicon       Silizium      Кремний > ],
		 15 => [ < Hosphoruspai    Phosphorus    Phosphorus    Phosphor      Фосфор > ],
		 16 => [ < Ulfursai        Sulfur        Sulphur       Schwefel      Сера > ],
		 17 => [ < Hlorinecai      Chlorine      Chlorine      Chlor         Хлор > ],
		 18 => [ < Rgonaai         Argon         Argon         Argon         Аргон > ],
		 19 => [ < Otassiumpai     Potassium     Potassium     Kalium        Калий > ],
		 20 => [ < Alciumcai       Calcium       Calcium       Calcium       Кальций > ],
		 21 => [ < Candiumsai      Scandium      Scandium      Scandium      Скандий > ],
		 22 => [ < Itaniumtai      Titanium      Titanium      Titan         Титан > ],
		 23 => [ < Anadiumvai      Vanadium      Vanadium      Vanadium      Ванадий > ],
		 24 => [ < Hromiumcai      Chromium      Chromium      Chrom         Хром > ],
		 25 => [ < Anganesemai     Manganese     Manganese     Mangan        Марганец > ],
		 26 => [ < Roniai          Iron          Iron          Eisen         Железо > ],
		 27 => [ < Obaltcai        Cobalt        Cobalt        Cobalt        Кобальт > ],
		 28 => [ < Ickelnai        Nickel        Nickel        Nickel        Никель > ],
		 29 => [ < Oppercai        Copper        Copper        Kupfer        Медь > ],
		 30 => [ < Inczai          Zinc          Zinc          Zink          Цинк > ],
		 31 => [ < Alliumgai       Gallium       Gallium       Gallium       Галлий > ],
		 32 => [ < Ermaniumgai     Germanium     Germanium     Germanium     Германий > ],
		 33 => [ < Rsenicaai       Arsenic       Arsenic       Arsen         Мышьяк > ],
		 34 => [ < Eleniumsai      Selenium      Selenium      Selen         Селен > ],
		 35 => [ < Rominebai       Bromine       Bromine       Brom          Бром > ],
		 36 => [ < Ryptonkai       Krypton       Krypton       Krypton       Криптон > ],
		 37 => [ < Ubidiumrai      Rubidium      Rubidium      Rubidium      Рубидий > ],
		 38 => [ < Trontiumsai     Strontium     Strontium     Strontium     Стронций > ],
		 39 => [ < Ttriumyai       Yttrium       Yttrium       Yttrium       Иттрий > ],
		 40 => [ < Irconiumzai     Zirconium     Zirconium     Zirconium     Цирконий > ],
		 41 => [ < Iobiumnai       Niobium       Niobium       Niob          Ниобий > ],
		 42 => [ < Olybdenummai    Molybdenum    Molybdenum    Molybdän      Молибден > ],
		 43 => [ < Echnetiumtai    Technetium    Technetium    Technetium    Технеций > ],
		 44 => [ < Utheniumrai     Ruthenium     Ruthenium     Ruthenium     Рутений > ],
		 45 => [ < Hodiumrai       Rhodium       Rhodium       Rhodium       Родий > ],
		 46 => [ < Alladiumpai     Palladium     Palladium     Palladium     Палладий > ],
		 47 => [ < Ilversai        Silver        Silver        Silber        Серебро > ],
		 48 => [ < Admiumcai       Cadmium       Cadmium       Cadmium       Кадмий > ],
		 49 => [ < Ndiumiai        Indium        Indium        Indium        Индий > ],
		 50 => [ < Intai           Tin           Tin           Zinn          Олово > ],
		 51 => [ < Ntimonyaai      Antimony      Antimony      Antimon       Сурьма > ],
		 52 => [ < Elluriumtai     Tellurium     Tellurium     Tellur        Теллур > ],
		 53 => [ < Odineiai        Iodine        Iodine        Iod           Иод > ],
		 54 => [ < Enonxai         Xenon         Xenon         Xenon         Ксенон > ],
		 55 => [ < Esiumcai        Cesium        Caesium       Cäsium        Цезий > ],
		 56 => [ < Ariumbai        Barium        Barium        Barium        Барий > ],
		 57 => [ < Anthanumlai     Lanthanum     Lanthanum     Lanthan       Лантан > ],
		 58 => [ < Eriumcai        Cerium        Cerium        Cer           Церий > ],
		 59 => [ < Raesodymiumpai  Praseodymium  Praseodymium  Praseodym     Празеодим > ],
		 60 => [ < Eodymiumnai     Neodymium     Neodymium     Neodym        Неодим > ],
		 61 => [ < Romethiumpai    Promethium    Promethium    Promethium    Прометий > ],
		 62 => [ < Amariumsai      Samarium      Samarium      Samarium      Самарий > ],
		 63 => [ < Uropiumeai      Europium      Europium      Europium      Европий > ],
		 64 => [ < Adoliniumgai    Gadolinium    Gadolinium    Gadolinium    Гадолиний > ],
		 65 => [ < Erbiumtai       Terbium       Terbium       Terbium       Тербий > ],
		 66 => [ < Ysprosiumdai    Dysprosium    Dysprosium    Dysprosium    Диспрозий > ],
		 67 => [ < Olmiumhai       Holmium       Holmium       Holmium       Гольмий > ],
		 68 => [ < Rbiumeai        Erbium        Erbium        Erbium        Эрбий > ],
		 69 => [ < Huliumtai       Thulium       Thulium       Thulium       Тулий > ],
		 70 => [ < Tterbiumyai     Ytterbium     Ytterbium     Ytterbium     Иттербий > ],
		 71 => [ < Utetiumlai      Lutetium      Lutetium      Lutetium      Лютеций > ],
		 72 => [ < Afniumhai       Hafnium       Hafnium       Hafnium       Гафний > ],
		 73 => [ < Antalumtai      Tantalum      Tantalum      Tantal        Тантал > ],
		 74 => [ < Ungstentai      Tungsten      Tungsten      Wolfram       Вольфрам > ],
		 75 => [ < Heniumrai       Rhenium       Rhenium       Rhenium       Рений > ],
		 76 => [ < Smiumoai        Osmium        Osmium        Osmium        Осмий > ],
		 77 => [ < Ridiumiai       Iridium       Iridium       Iridium       Иридий > ],
		 78 => [ < Latinumpai      Platinum      Platinum      Platin        Платина > ],
		 79 => [ < Oldgai          Gold          Gold          Gold          Золото > ],
		 80 => [ < Ercurymai       Mercury       Mercury       Quecksilber   Ртуть > ],
		 81 => [ < Halliumtai      Thallium      Thallium      Thallium      Таллий > ],
		 82 => [ < Eadlai          Lead          Lead          Blei          Свинец > ],
		 83 => [ < Ismuthbai       Bismuth       Bismuth       Bismut        Висмут > ],
		 84 => [ < Oloniumpai      Polonium      Polonium      Polonium      Полоний > ],
		 85 => [ < Statineaai      Astatine      Astatine      Astat         Астат > ],
		 86 => [ < Adonrai         Radon         Radon         Radon         Радон > ],
		 87 => [ < Ranciumfai      Francium      Francium      Francium      Франций > ],
		 88 => [ < Adiumrai        Radium        Radium        Radium        Радий > ],
		 89 => [ < Ctiniumaai      Actinium      Actinium      Actinium      Актиний > ],
		 90 => [ < Horiumtai       Thorium       Thorium       Thorium       Торий > ],
		 91 => [ < Rotactiniumpai  Protactinium  Protactinium  Protactinium  Протактиний > ],
		 92 => [ < Raniumuai       Uranium       Uranium       Uran          Уран > ],
		 93 => [ < Eptuniumnai     Neptunium     Neptunium     Neptunium     Нептуний > ],
		 94 => [ < Lutoniumpai     Plutonium     Plutonium     Plutonium     Плутоний > ],
		 95 => [ < Mericiumaai     Americium     Americium     Americium     Америций > ],
		 96 => [ < Uriumcai        Curium        Curium        Curium        Кюрий > ],
		 97 => [ < Erkeliumbai     Berkelium     Berkelium     Berkelium     Берклий > ],
		 98 => [ < Aliforniumcai   Californium   Californium   Californium   Калифорний > ],
		 99 => [ < Insteiniumeai   Einsteinium   Einsteinium   Einsteinium   Эйнштейний > ],
		100 => [ < Ermiumfai       Fermium       Fermium       Fermium       Фермий > ],
		101 => [ < Endeleviummai   Mendelevium   Mendelevium   Mendelevium   Менделевий > ],
		102 => [ < Obeliumnai      Nobelium      Nobelium      Nobelium      Нобелий > ],
		103 => [ < Awerenciumlai   Lawrencium    Lawrencium    Lawrencium    Лоуренсий > ],
		104 => [ < Utherfordiumrai Rutherfordium Rutherfordium Rutherfordium Курчатовий > ],
		105 => [ < Ubniumdai       Dubnium       Dubnium       Dubnium       Нильсборий > ],
		106 => [ < Eaborgiumsai    Seaborgium    Seaborgium    Seaborgium    Сиборгий > ],
		107 => [ < Ohriumbai       Bohrium       Bohrium       Bohrium       Борий > ],
		108 => [ < Assiumhai       Hassium       Hassium       Hassium       Хассий > ],
		109 => [ < Eitneriummai    Meitnerium    Meitnerium    Meitnerium    Майтнерий > ],
		110 => [ < Armstadtiumdai  Darmstadtium  Darmstadtium  Darmstadtium  Дармштадтий > ],
		111 => [ < Oentgeniumrai   Roentgenium   Roentgenium   Roentgenium   Рентгений > ],
		112 => [ < Operniciumcai   Copernicium   Copernicium   Copernicium   Коперниций > ],
		113 => [ < Ihoniumnai      Nihonium      Nihonium      Nihonium      Нихоний > ],
		114 => [ < Leroviumfai     Flerovium     Flerovium     Flerovium     Флеровий > ],
		115 => [ < Oscoviummai     Moscovium     Moscovium     Moscovium     Московий > ],
		116 => [ < Ivermoriumlai   Livermorium   Livermorium   Livermorium   Ливерморий > ],
		117 => [ < Ennessinetai    Tennessine    Tennessine    Tennessine    Теннессин > ],
		118 => [ < Ganessonoai     Oganesson     Oganesson     Oganesson     Оганесон > ],

		);

	# https://rt.perl.org/Ticket/Display.html?id=126763
	# http://stackoverflow.com/q/40097868/2766176
	#|{
	A Str that is one of the known chemical symbols
	}
	subset ZInt of Cool is export where {
		state ( $min, $max ) = %names.keys.sort( { $^a <=> $^b } ).[0,*-1];
		( $_.truncate == $_ and $min <= $_ <= $max )
			or
		note "Expected a known atomic number between $min and $max, but got $_"
			and
		False;
		};

	#|{ Return the maximum recognized atomic number (as a ZInt type). }
	method max_Z () returns ZInt {
		state $max = %names.keys.sort( { $^b <=> $^a } ).[0];
		$max;
		}

	#|{ Return the minimum recognized atomic number. This is always be 1 (as a ZInt type). }
	method min_Z () returns ZInt {
		state $min = %names.keys.sort( { $^a <=> $^b } ).[0];
		$min;
		}

	my @elements = <
	H                                                                                            He
	Li Be                                                                          B  C  N  O  F Ne
	Na Mg                                                                         Al Si  P  S Cl Ar
	K  Ca                                           Sc Ti  V Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr
	Rb Sr                                            Y Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te  I Xe
	Cs Ba La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb Lu Hf Ta W  Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn
	Fr Ra Ac Th Pa U  Np Pu Am Cm Bk Cf Es Fm Md No Lr Rf Ha Sg Bh Hs Mt Ds Rg Cn Nh Fl Mc Lv Ts Og
	>
		==> map( { state $n = 0; $n++; $_.Str => item $n } )
		==> my %symbol_to_name;

	# I could perhaps use Z=> above
	# http://stackoverflow.com/questions/39307797/can-i-return-multiple-pairs-from-a-map-feeding-into-a-hash
	#|{
	A Str that is one of the known chemical symbols
	}
	subset ChemicalSymbol of Str is export where {
		%symbol_to_name{$_}:exists
			or
		note "Expected a defined ChemicalSymbol (Chemistry::Elements)." ~ " Got $_"
			and
		False;
		};

	# In the following functions $lang is used to declare the language for the query/result.
	# The lang_str_to_int method converts the language string to the language index.

	method lang_str_to_column (Str $lang) returns Int {
		return do given $lang {
			when %language_column{$lang}:exists { %language_column{$lang} }
			default                             { %language_column{'en'}  }
			}
		}

	#|{
	Return the element name by the atomic number. You can pass an untyped
	number or a ZInt
	}
	method get_name_by_Z ( ZInt(Cool) $Z, Str $lang = "default" ) returns Str {
		%names{$Z}[self.lang_str_to_column($lang)];
		}

	#|{
	Return the element name (as a Str) by the ChemicalSymbol. You can provide a second
	argument to choose the language.
	}
	method get_name_by_symbol ( ChemicalSymbol $symbol, Str $lang = "default" ) returns Str {
		self.get_name_by_Z( self.get_Z_by_symbol( $symbol ), $lang );
		}

	#|{
	Return the chemical symbol (as a ChemicalSymbol type) by
	the atomic number.
	}
	method get_symbol_by_Z ( ZInt(Cool) $Z ) returns ChemicalSymbol {
		@elements[$Z - 1].Str;
		}
	#|{
	Return the chemical symbol (as a ChemicalSymbol object) by
	the element name.
	}
	method get_symbol_by_name ( Str $name ) returns ChemicalSymbol {
		self.get_symbol_by_Z( self.get_Z_by_name( $name ) );
		}

	#|{
	Return the atomic number (as a ZInt type) by the ChemicalSymbol.
	}
	method get_Z_by_symbol ( ChemicalSymbol $symbol ) returns ZInt {
		%symbol_to_name{$symbol}:exists ?? %symbol_to_name{$symbol} !! die;
		}

	#|{
	Return the atomic number (as a ZInt type) by the element name.
	}
	method get_Z_by_name ( Str $name, Str $lang = "default" ) returns ZInt {
		die "get_Z_by_name not yet implemented";
		}

	}

=begin pod

=head1 TO DO

=item Integrate the other languages in the F<Lib/Languages> directory.

=item Guess the langauge based on a name or symbol

=item Allow historical symbols that aren't

=head1 SEE ALSO

=head1 SOURCE AVAILABILITY

This module is in Github:

	https://github.com/briandfoy/perl6-chemistry-elements

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2016-2018, brian d foy <bdfoy@cpan.org>. All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the Artistic License 2.0.

=end pod
