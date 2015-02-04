use Phaser::ATEXIT;
use Test;

ATEXIT { done }
ATEXIT { ok True, "Run at exit" }
ok True, "We are here!";