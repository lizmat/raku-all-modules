use NativeCall;
use SDL2::Raw;
use Cairo;
use nqp;

use lib 'lib';
use SDL2;

constant W = 1280;
constant H = 960;

constant REFRACT_PROB = 30;
constant ENEMY_PROB = 5;

class Object is rw {
    has Complex $.pos;
    has Complex $.vel;
    has Int $.id = ^4096 .pick;
    has Num $.lifetime;
}

class Enemy is Object is rw {
    has Int $.HP;
}

my $player = Object.new( :pos(H / 2 + (H * 6 / 7)\i) );

die "couldn't initialize SDL2: { SDL_GetError }" if SDL_Init(VIDEO) != 0;
LEAVE SDL_Quit;


for ^SDL_GetNumRenderDrivers() {
    my $foo = SDL_RendererInfo.new;
    SDL_GetRenderDriverInfo($_, $foo);
    say $foo.perl;
}

my $window = SDL2::Window.new(
  :title("Space Shooter!"),
  :width(W),
  :height(H)
);
my $render = SDL2::Renderer.new($window);

$render.logical-size(:width(1920), :height(960));

my @starfields = do for ^4 {
    my $texture = $render.create-texture(
      :format(%PIXELFORMAT<ARGB8888>),
      :access(TARGET),
      :width(W),
      :height(H * 2)
    );

    $render.render-target($texture);
    $render.draw-color(0, 0, 0, 0);
    $render.clear;
    $render.draw-color(255, 255, 255, (255 * (1 - $_ * 0.2)).Int);

    for ^250 {
        my ($x, $y) = ^W .pick, ^H .pick;
        $render.draw-point($x, $y);
        $render.draw-point($x, $y + H);
    }

    SDL_SetTextureBlendMode($texture, 1);

    $texture;
};
$render.render-target(SDL_Texture);

my $enemy_image = Cairo::Image.record(
    -> $_ {
        .translate(64, 64);
        .scale(3, 3);
        .move_to(5, -15);
        .line_to(-5, -15);
        .curve_to(-30, -15, -15, 15, -5, 15);
        .line_to(-3, -5);
        .line_to(0, 5);
        .line_to(3, -5);
        .line_to(5, 15);
        .curve_to(15, 15, 30, -15, 5, -15);
        .line_to(5, -15);

        .line_to(0, -5) :relative;
        .line_to(-10, 0) :relative;
        .line_to(0, 5) :relative;

        .rgb(0.9, 0.2, 0.1);
        .fill :preserve;
        .rgb(1, 1, 1);
        .stroke;
    }, 128, 128, Cairo::FORMAT_ARGB32);


my $player-image = Cairo::Image.record(
    -> $_ {
        .translate(64, 64);
        .scale(1.5, 1.5);
        .line_width = 4;
        .rgb(1, 1, 1);

        .move_to(-1, -29);
        .line_to(0, -8) :relative;
        .line_to(2, 0) :relative;
        .line_to(0, 8) :relative;
        .close_path;

        .move_to(5, -30);
        for ( -10, 0,  -5, 5,  -5, 20,  5, 5,  -10, 10,  -15, -5,
              0, -20,  -2, 0,   0, 35,  22, 5,  0, -5,  30, 0,  0, 5,  22, -5,
              0, -35,  -2, 0,  0, 20,  -15, 5,  -10, -10,  5, -5,  -5, -20) -> $x, $y {
            .line_to($x, $y) :relative;
        }
        .close_path;
  
        .stroke :preserve;
        .rgb(0.75, 0.75, 0.75);
        .fill;

        .rgb(0.5, 0.5, 0.5);

        .move_to(6, -5);
        .line_to(-12, 0) :relative;
        .line_to(-1, -6) :relative;
        .line_to(3, -10) :relative;
        .line_to(9, 0) :relative;
        .line_to(3, 10) :relative;
        .close_path;

        .stroke :preserve;
        .rgb(0.2, 0.2, 0.2);
        .fill;
    }, 128, 128, Cairo::FORMAT_ARGB32);

my $enemy_texture = $render.create-texture(
  :format(%PIXELFORMAT<ARGB8888>),
  :access(STATIC),
  :width(128),
  :height(128)
);
SDL_UpdateTexture($enemy_texture, SDL_Rect.new(0, 0, 128, 128), $enemy_image.data, $enemy_image.stride // 128 * 4);
SDL_SetTextureBlendMode($enemy_texture, 1);

my $player_texture = $render.create-texture(
  :format(%PIXELFORMAT<ARGB8888>),
  :access(STATIC),
  :width(128),
  :height(128)
);

SDL_UpdateTexture($player_texture, SDL_Rect.new(0, 0, 128, 128), $player-image.data, $player-image.stride // 128 * 4);
SDL_SetTextureBlendMode($player_texture, 1);

$render.blend-mode(BLENDMODE_BLEND);

my $event = SDL_Event.new;

enum GAME-KEYS (
    K_UP    => 82,
    K_DOWN  => 81,
    K_LEFT  => 80,
    K_RIGHT => 79,
    K_SPACE => 44,
);

my %down-keys;

my @bullets;
my @enemies;
my @enemies-freelist;
my @shieldbounces;
my @kills;
my $nextreload = 0;
my $explosion-background = 0;

my num $last_frame_start = nqp::time_n();

main: loop {
    my num $start = nqp::time_n();
    my $dt = $start - $last_frame_start // 0.00001;
    while SDL_PollEvent($event) {
        my $casted-event = SDL_CastEvent($event);

        given $casted-event {
            when *.type == QUIT {
                last main;
            }
            when *.type == KEYDOWN {
                if GAME-KEYS(.scancode) -> $comm {
                    %down-keys{$comm} = 1;
                } else { say "new keycode found: $_.scancode()"; }

                CATCH { say $_ }
            }
            when *.type == KEYUP {
                if GAME-KEYS(.scancode) -> $comm {
                    %down-keys{$comm} = 0;
                } else { say "new keycode found: $_.scancode()"; }

                CATCH { say $_ }
            }
        }
    }

    $explosion-background -= $dt if $explosion-background > 0;

    if %down-keys<K_LEFT> && $player.pos.re > 20 {
        $player.pos -= 400 * $dt;
    }
    if %down-keys<K_RIGHT> && $player.pos.re < W - 20 {
        $player.pos += 400 * $dt;
    }

    if %down-keys<K_SPACE> {
        if $start > $nextreload && !defined $player.lifetime {
            @bullets.push(Object.new(:pos($player.pos), :vel(0 - 768i)));
            $nextreload = $start + 0.2;
        }
    }

    for flat @bullets, @shieldbounces {
        $_.pos += $dt * $_.vel;
        $_.lifetime -= $dt if defined $_.lifetime;
    }
    @bullets .= grep(
        -> $b {
            my $p = $b.pos;
            0 < $b.pos.re < W
            and 0 < $b.pos.im < H
    });

    for @enemies {
        if $_.pos.re < 15 && $_.vel.re < 0 {
            $_.vel = -$_.vel.re + $_.vel.im\i
        }
        if $_.pos.re > W - 15 && $_.vel.re > 0 {
            $_.vel = -$_.vel.re + $_.vel.im\i
        }
        unless defined $_.lifetime {
            if $_.vel.im < 182 && ($_.id > 128 || $_.pos.im < H / 4) {
                $_.vel += ($dt * 100)\i;
                my $polarvel = $_.vel.polar;
                $_.vel = unpolar($polarvel[0] min 182, $polarvel[1]);
            } elsif $_.id <= 128 {
                if $_.pos.im > H / 4 {
                    if $_.vel.im > 16 {
                        $_.vel *= 0.9
                    }
                }
            }
        }

        $_.pos += $dt * $_.vel;

        if $_.lifetime {
            $_.lifetime -= $dt;
            $_.vel *= 0.8;
        } else {
            unless defined $player.lifetime {
                for @bullets -> $b {
                    next unless -20 < $b.pos.re - $_.pos.re < 20;
                    next unless -20 < $b.pos.im - $_.pos.im < 20;

                    my $posdiff   = ($_.pos - $b.pos);
                    my $polardiff = $posdiff.polar;
                    if $polardiff[0] < 35 {
                        if $_.HP == 0 {
                            $_.lifetime = 2e0;
                            $_.vel += $b.vel / 4;
                            $_.vel *= 4;
                            if 100.rand < REFRACT_PROB && @bullets < 50 {
                                for ^4 {
                                    @bullets.push:
                                        Object.new: :pos($b.pos), :vel(unpolar(768, (2 * π).rand));
                                }
                            }
                            @kills.push($_);
                            $explosion-background = 0.9 + 0.1.rand;
                        } elsif $_.HP > 0 {
                            next if $_.HP <= 2 && $polardiff >= 25;
                            $_.HP--;
                            my $bumpdiff = unpolar(1, ($posdiff - 30i).polar[1]);
                            $_.vel += $bumpdiff * ($_.HP > 2 ?? 25 !! 200) - 96i;
                            if $_.HP >= 2 {
                                @shieldbounces.push:
                                    Object.new: :pos($_.pos),
                                                :vel($_.vel),
                                                :lifetime(0.25e0);
                            }
                        }
                        $b.pos -= 1000i;
                        last;
                    }
                }
            }

            if ($player.pos - $_.pos).polar[0] < 40 {
                $player.lifetime //= 3e0;
                $explosion-background = 1e0;
            }
        }
    }
    @enemies-freelist.append: @enemies.grep({ not ($_.pos.im < H + 30 && (!.lifetime || .lifetime > 0)) });
    @enemies .= grep({ $_.pos.im < H + 30 && (!$_.lifetime || $_.lifetime > 0) });
    @shieldbounces.shift while @shieldbounces and @shieldbounces[0].lifetime <= 0;

    if 100.rand < ENEMY_PROB && @enemies < 100 {
        if @enemies-freelist {
            my $enemy = @enemies-freelist.pop;
            $enemy.pos = (W - 24).rand + 12 - 15i;
            $enemy.vel = (100.rand - 50) + 182i;
            $enemy.HP = 3;
            $enemy.lifetime = Num;
            $enemy.id = ^4096 .pick;
            @enemies.push($enemy);
        } else {
            @enemies.push: Enemy.new:
                :pos((W - 24).rand + 12 - 15i),
                :vel((100.rand - 50) + 182i),
                :HP(3);
        }
    }

    $render.draw-color(0, 0, 0, 0);
    $render.clear;

    my @yoffs  = ((nqp::time_n() * -100) % H).Int,
                 ((nqp::time_n() *  -80) % H).Int,
                 ((nqp::time_n() *  -50) % H).Int,
                 ((nqp::time_n() *  -15) % H).Int;

    $render.draw-color(255, 255, 255, 255);
    my SDL_Rect $srcrect .= new: x => 0, y => 0, w => W, h => H;
    for ^4 {
        $srcrect.y = @yoffs.AT-POS($_).Int;
        $render.render-copy( @starfields.AT-POS($_), $srcrect, SDL_Rect);
    }

    $srcrect.x = ($player.pos.re - 32).Int;
    $srcrect.y = ($player.pos.im - 32).Int;
    $srcrect.w = 64;
    $srcrect.h = 64;
    $render.render-copy($player_texture, SDL_Rect, $srcrect);

    for @enemies {
        $srcrect.x = (.pos.re - 32).Int;
        $srcrect.y = (.pos.im - 32).Int;
        $render.render-copy($enemy_texture, SDL_Rect, $srcrect);
    }

    $render.draw-color(78, 78, 255, 255);
    $srcrect.w = 6;
    $srcrect.h = 16;
    for @bullets {
        $srcrect.x = (.pos.re - 3).Int;
        $srcrect.y = (.pos.im - 8).Int;
        $render.fill-rect($srcrect);
    }

    $render.present;

    $last_frame_start = $start;
}
