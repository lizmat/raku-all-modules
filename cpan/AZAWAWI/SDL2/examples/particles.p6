use SDL2::Raw;
use lib 'lib';
use SDL2;

my int ($w, $h) = 800, 600;

my int $particlenum = 1000;

die "couldn't initialize SDL2: { SDL_GetError }" if SDL_Init(VIDEO) != 0;
LEAVE SDL_Quit;

my $window = SDL2::Window.new(
  :title("Particle System!"),
  :width($w),
  :height($h),
  :flags(SHOWN)
);
LEAVE $window.destroy;
my $renderer = SDL2::Renderer.new( $window, :flags(ACCELERATED) );
LEAVE $renderer.destroy;

SDL_ClearError;

my $renderer_info = $renderer.renderer-info;
say $renderer_info;

say %PIXELFORMAT.pairs.grep({ $_.value == any($renderer_info.texf1, $renderer_info.texf2, $renderer_info.texf3) });

my num @positions = 0e0 xx ($particlenum * 2);
my num @velocities = 0e0 xx ($particlenum * 2);
my num @lifetimes = 0e0 xx $particlenum;

sub update($df) {
    my int $xidx = 0;
    my int $yidx = 1;
    my @points;
    loop (my int $idx = 0; $idx < $particlenum; $idx = $idx + 1) {
        my int $willdraw = 0;
        if (@lifetimes[$idx] <= 0e0) {
            if (rand < $df) {
                @lifetimes[$idx] = rand * 10e0;
                @positions[$xidx] = ($w / 20e0).Num;
                @positions[$yidx] = (3 * $h / 50).Num;
                @velocities[$xidx] = (rand - 0.5e0) * 10;
                @velocities[$yidx] = (rand - 2e0) * 10;
                $willdraw = 1;
            }
        } else {
            if @positions[$yidx] > $h / 10 && @velocities[$yidx] > 0 {
                @velocities[$yidx] = @velocities[$yidx] * -0.6e0;
            }

            @velocities[$yidx] = @velocities[$yidx] + 9.81e0 * $df;
            @positions[$xidx] = @positions[$xidx] + @velocities[$xidx] * $df;
            @positions[$yidx] = @positions[$yidx] + @velocities[$yidx] * $df;

            @lifetimes[$idx] = @lifetimes[$idx] - $df;
            $willdraw = 1;
        }

        if $willdraw {
            @points.push: %(
              x => (@positions[$xidx] * 10).floor,
              y => (@positions[$yidx] * 10).floor,
            )
        }

        $xidx = $xidx + 2;
        $yidx = $xidx + 1;
    }
    @points;
}

sub render(@points) {
    $renderer.draw-color(0x0, 0x0, 0x0, 0xff);
    $renderer.clear;

    $renderer.draw-color(0xff, 0xff, 0xff, 0x7f);
    $renderer.draw-points(@points);

    $renderer.present;
}

my $event = SDL_Event.new;

my @times;
my $df = 0.0001e0;

main: loop {
    my $start = now;

    while SDL_PollEvent($event) {
        my $casted_event = SDL_CastEvent($event);

        given $casted_event {
            when *.type == QUIT {
                last main;
            }
        }
    }

    my @points = update($df);
    render(@points);

    $df = now - $start;
}
