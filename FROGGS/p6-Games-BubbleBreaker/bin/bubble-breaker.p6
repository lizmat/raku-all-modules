#!perl6

use SDL;
#use SDL::Event;
#use SDL::Events;
#use SDL::Mouse;
use SDL::Video;
#use SDL::VideoInfo;
use SDL::Surface;
use SDL::App;
#use SDLx::Surface;
use SDL::SFont;

say "
**************************** Information **********************************
Click on a bubble to select all contiguous bubbles of same color and double
click to destroy them. The more bubbles you destroy at once the more points
you get.

To quit press ESC.

Have fun!
***************************************************************************
";

my $videodriver          = %*ENV{'SDL_VIDEODRIVER'};
%*ENV{'SDL_VIDEODRIVER'} = 'dummy' if %*ENV{'BUBBLEBREAKER_TEST'};

# initializing video and retrieving current video resolution
SDL::init( 32 );
%*ENV{'SDL_VIDEO_CENTERED'} = 'center';
#my $app                    = SDL::App.new( 800, 352, 32, 1073741856 );
my $app                     = SDL::App.new( 800, 352, 32, 0 );
#my $app                    = SDLx::App->new( width => 800, height => 352,
#                                             depth => 32,  title  => "BubbleBreaker", color => 0x000000FF,
#                                             init  => 0,   eoq    => 1,               delay => 20,
#                                             flags => SDL_SWSURFACE +| SDL_DOUBLEBUF +| SDL_NOFRAME );
my $HOME                    = $*OS ~~ 'MSWin32'
                            ?? %*ENV{'HOMEDRIVE'} ~ '/' ~ %*ENV{'HOMEPATH'} ~ '/.bubble-breaker'
                            !! "%*ENV{'HOME'}/.bubble-breaker";
my $SHARE                   = 'share';
my $last_click              = now;
my $sfont_white             = SDL::SFont.new( "$SHARE/font_white.png" );
my $sfont_blue              = SDL::SFont.new( "$SHARE/font_blue.png" );
mkdir($HOME) unless $HOME.IO.d;

# ingame states
my $points      = 0;
my @controls    = ();
my %balls       = ();
my $neighbours  = {};
my @highscore   = ();

# images
my $background = SDL::Surface.new( "$SHARE/background.png" );
my @balls      = (
	SDL::Surface.new( "$SHARE/red.png" ),
	SDL::Surface.new( "$SHARE/green.png" ),
	SDL::Surface.new( "$SHARE/yellow.png" ),
	SDL::Surface.new( "$SHARE/pink.png" ),
	SDL::Surface.new( "$SHARE/blue.png" )
);

new_round();

# TODO push_event
#if(%*ENV{'BUBBLEBREAKER_TEST'}) {
#    $app->add_show_handler(  sub {
#        if(SDL::get_ticks > 1000) {
#            my $esc_event = SDL::Event->new();
#            $esc_event->type(SDL_KEYDOWN);
#            $esc_event->key_sym(SDLK_ESCAPE);
#            SDL::Events::push_event($esc_event);
#        }
#        elsif(SDL::get_ticks > 3000) {
#            $app->stop;
#        }
#    } );
#}

$app.add_show_handler( sub { $app.update } );

# main event loop
$app.add_event_handler( sub ( $e ) {
	if ($e.type == SDL::Event::SDL_KEYDOWN) && ($e.key_sym == SDL::Event::SDLK_ESCAPE)
	|| ($e.type == SDL::Event::SDL_QUIT) {
		$app.stop;
	}
	elsif ($e.type == SDL::Event::SDL_MOUSEBUTTONDOWN) && ($e.button_button == SDL::Event::SDL_BUTTON_LEFT) {
		my $time = now;

		if $e.button_x >= 278 && $e.button_x <= 278 + 15 * 25
		&& $e.button_y >=  28 && $e.button_y <=  28 + 12 * 25 {
			if $time - $last_click < 0.8 && remove_selection( $neighbours ) {
				$neighbours = {};
				$background.blit( $app );

				# redraw everything because columns might be moved to the middle
				for 0..14 -> $x {
					for 0..11 -> $y {
						if %balls{$x}{$y}.defined {
							@balls[%balls{$x}{$y}].blit( $app, SDL::Rect, SDL::Rect.new( 280 + $x * 25, 30 + $y * 25, 0, 0 ) );
						}
					}
				}
			}
			else {
				# redraw previous selection
				for $neighbours.keys -> $x {
					for $neighbours{$x}.keys -> $y {
						$background.blit( $app, SDL::Rect.new( 278 + $x * 25, 28 + $y * 25, 28, 28 ), SDL::Rect.new( 278 + $x * 25, 28 + $y * 25, 0, 0 ) );
						@balls[ %balls{$x}{$y} ].blit( $app, SDL::Rect, SDL::Rect.new( 280 + $x * 25, 30 + $y * 25, 0, 0 ) );
					}
				}

				my $control = @controls[ (($e.button_x - 278) / 25).Int * 12 + (($e.button_y - 28) / 25).Int ];

				if %balls{ $control[4] }{ $control[5] }.defined {
					$neighbours = {};
					neighbours( $control[4], $control[5], $neighbours );
					draw_shape( $neighbours );
				}
			}
		}
		elsif ( 20 < $e.button_x) && ($e.button_x < 220)
		   && (235 < $e.button_y) && ($e.button_y < 280) {
			new_round();
		}
		$last_click = $time;
		$sfont_blue.blit_text( $app, 250 - $sfont_white.text_width( $points ), 160, $points );
		draw_highscore();
	}
} );

$app.run;

sub new_round {
	$points     = 0;
	@controls   = ();
	%balls      = ();
	$neighbours = {};
	@highscore  = ();

	$background.blit( $app );
	draw_highscore();

	for 0..14 -> $x {
		for 0..11 -> $y {
			my $color      = 5.rand.Int;
			%balls{$x}{$y} = $color;
			@balls[$color].blit( $app, SDL::Rect, SDL::Rect.new( 280 + $x * 25, 30 + $y * 25, 0, 0 ) );
			@controls.push: [ 278 + $x * 25, 28 + $y * 25, 303 + $x * 25, 53 + $y * 25, $x, $y ];
		}
	}
}

sub draw_highscore {
	unless @highscore {
		if !"$HOME/highscore.dat".IO.e && my $fh = open( "$HOME/highscore.dat", :w ) {
			$fh.print( "42\n" );
			$fh.close;
		}

		@highscore = "$HOME/highscore.dat".IO.lines
	}

	my $line         = 0;
	my @score        = (@highscore, $points).sort: { $^b <=> $^a };
	my $points_drawn = 0;
	while $line < 10 && @score[$line] {
		if @score[$line] == $points && !$points_drawn {
			$sfont_white.blit_text( $app, 780 - $sfont_white.text_width( @score[$line] ), 60 + 25 * $line, @score[$line++] );
			$points_drawn = 1;
		}
		else {
			$sfont_blue.blit_text( $app, 780 - $sfont_blue.text_width( @score[$line] ), 60 + 25 * $line, @score[$line++] );
		}
	}

	if my $fh = open( "$HOME/highscore.dat", :w ) {
		$fh.print( "$_\n" ) for @score;
		$fh.close;
	}
}

sub remove_selection ( $n ) {
	my $count = 0;
	for $n.keys -> $x {
		for $n{$x}.keys -> $y {
			%balls{$x}{$y} = Int;
			$count++;
		}
	}

	return unless $count;

	$points += (5 * $count + 1.5**$count).Int;
	
	my $removed = False;

	for 0..14 -> $x {
		for 0..11 {
			my $y = 11 - $_;
			unless %balls{$x}{$y}.defined {
				my $above = $y - 1;
				$above--while !%balls{$x}{$above}.defined && $above > 0;

				%balls{$x}{$y}     = %balls{$x}{$above};
				%balls{$x}{$above} = Int;
				$removed           = True;
			}
		}
	}

	for 0..7 -> $_x {
		my $x = 7 - $_x;
		unless %balls{$x}{11}.defined {
			my $left = $x - 1;
			$left-- while !%balls{$left}{11}.defined && $left > 0;

			for 0..11 {
				my $y = 11 - $_;
				%balls{$x}{$y}    = %balls{$left}{$y};
				%balls{$left}{$y} = Int;
				$removed          = True;
			}
		}
	}

	for 7..14 -> $x {
		unless %balls{$x}{11}.defined {
			my $right = $x + 1;
			$right++ while !%balls{$right}{11}.defined && $right < 14;

			for 0..11 {
				my $y = 11 - $_;
				%balls{$x}{$y}     = %balls{$right}{$y};
				%balls{$right}{$y} = Int;
				$removed           = True;
			}
		}
	}
}

sub draw_shape ( $n ) {
	my %lines = ();

	for $n.keys -> $x {
		for $n{$x}.keys -> $y {
			%lines{278 + $x * 25}{28 + $y * 25}{303 + $x * 25}{28 + $y * 25}++;
			%lines{278 + $x * 25}{53 + $y * 25}{303 + $x * 25}{53 + $y * 25}++;
			%lines{278 + $x * 25}{28 + $y * 25}{278 + $x * 25}{53 + $y * 25}++;
			%lines{303 + $x * 25}{28 + $y * 25}{303 + $x * 25}{53 + $y * 25}++;
		}
	}

	for %lines.keys -> $x1 {
		for %lines{$x1}.keys -> $y1 {
			for %lines{$x1}{$y1}.keys -> $x2 {
				for %lines{$x1}{$y1}{$x2}.keys -> $y2 {
					if %lines{$x1}{$y1}{$x2}{$y2} == 1 {
						$app.draw_line( $x1.Int, $y1.Int, $x2.Int, $y2.Int, 0x153C99 );
					}
				}
			}
		}
	}
}

sub neighbours ( $x, $y, $n ) {
	if %balls{$x}{$y - 1}.defined && %balls{$x}{$y - 1} == %balls{$x}{$y} && !$n{$x}{$y - 1} {
		$n{$x}{$y}     = 1;
		$n{$x}{$y - 1} = 1;
		neighbours($x, $y - 1, $n);
	}
	
	if %balls{$x}{$y + 1}.defined && %balls{$x}{$y + 1} == %balls{$x}{$y} && !$n{$x}{$y + 1} {
		$n{$x}{$y}     = 1;
		$n{$x}{$y + 1} = 1;
		neighbours($x, $y + 1, $n);
	}
	
	if %balls{$x - 1}{$y}.defined && %balls{$x - 1}{$y} == %balls{$x}{$y} && !$n{$x - 1}{$y} {
		$n{$x}{$y}     = 1;
		$n{$x - 1}{$y} = 1;
		neighbours($x - 1, $y, $n);
	}
	
	if %balls{$x + 1}{$y}.defined && %balls{$x + 1}{$y} == %balls{$x}{$y} && !$n{$x + 1}{$y} {
		$n{$x}{$y}     = 1;
		$n{$x + 1}{$y} = 1;
		neighbours($x + 1, $y, $n);
	}
}

if $videodriver {
	%*ENV{'SDL_VIDEODRIVER'} = $videodriver;
} else {
	%*ENV{'SDL_VIDEODRIVER'} = Str;
}
