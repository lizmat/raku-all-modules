# SDL2

 [![Build Status](https://travis-ci.org/azawawi/perl6-sdl2.svg?branch=master)](https://travis-ci.org/azawawi/perl6-sdl2) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-sdl2?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-sdl2/branch/master)

This module adds some OO-sugar on top of [`SDL2::Raw`](https://github.com/timo/SDL2_raw-p6/).

**Note: This is currently experimental and API may change. Please DO NOT use in
a production environment.**

## Example

```perl6
use v6;

use SDL2::Raw;
use SDL2;

die "couldn't initialize SDL2: { SDL_GetError }" if SDL_Init(VIDEO) != 0;
LEAVE SDL_Quit;

my $window = SDL2::Window.new(:title("Hello, world!"), :flags(OPENGL));
LEAVE $window.destroy;

my $render = SDL2::Renderer.new($window);
LEAVE $render.destroy;

my $event = SDL_Event.new;

main: loop {
  $render.draw-color(0, 0, 0, 0);
  $render.clear;

  while SDL_PollEvent($event) {
    last main if $event.type == QUIT;
  }

  $render.draw-color(255, 255, 255, 255);
  $render.fill-rect(
    SDL_Rect.new(
      2 * min(now * 300 % 800, -now * 300 % 800),
      2 * min(now * 470 % 600, -now * 470 % 600),
    sin(3 * now) * 50 + 80, cos(4 * now) * 50 + 60));

  $render.present;
}
```

More examples can be found in [`examples`](examples/) folder.

## Installation

Please see [`SDL2::Raw`](https://github.com/timo/SDL2_raw-p6/) for `libsdl2` platform dependencies.

```
$ zef install sdl2
```

## Testing

- To run tests:
```
$ prove -ve "perl6 -Ilib"
```

- To run all tests including author tests (Please make sure
[Test::Meta](https://github.com/jonathanstowe/Test-META) is installed):
```
$ zef install Test::META
$ AUTHOR_TESTING=1 prove -e "perl6 -Ilib"
```

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6

## License

MIT License
