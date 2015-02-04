module Phaser {
    sub ATEXIT(&code) is export {
        state @blocks;
        @blocks.push(&code);
        END { for @blocks.reverse -> &code { &code() } }
    }
}