#
# Dynamically setting a window title
#
# Adapted to Perl 6 from
# https://wiki.libsdl.org/SDL_SetWindowTitle?highlight=%28%5CbCategoryVideo%5Cb%29%7C%28CategoryEnum%29%7C%28CategoryStruct%29
#

use v6;
use lib 'lib';
use SDL2;
use SDL2::Raw;

# just for fun, let's make the title animate like a marquee and annoy users
my @titles = (  
    "t", "thi", "this w", "this win", "this windo", "this window's", "this window's ti", "this window's title",
    "chis window's title is", "chih window's title is ", "chih wandnw's title is ", "c  h wandnw'g title is ",
    "c  h  a  nw'g titln is ", "c  h  a  n  g  i  n ig ", "c  h  a  n  g  i  n  g!", "",
    "c  h  a  n  g  i  n  g!", "", "c  h  a  n  g  i  n  g!", "c  h  a  n  g  i  n  g!"
);

# Initialize SDL2
die "couldn't initialize SDL2: { SDL_GetError }" if SDL_Init(VIDEO) != 0;
LEAVE SDL_Quit;

# Create a window.
my $window = SDL2::Window.new(
  :width(320), :height(240),
  :flags(RESIZABLE)
);
LEAVE $window.destroy;

# Enter the main loop.
my $i = 0;
my $frames = 0;
my $e = SDL_Event.new;
loop {

  # Exit if the window is closed or a key is pressed
  SDL_PollEvent($e);
  last if $e.type == QUIT || $e.type == KEYDOWN;

  if ++$frames % 9 == 0 {
    # Every 9th frame...
    $window.title: @titles[++$i % @titles.elems];
  }

  sleep 0.01;
}
