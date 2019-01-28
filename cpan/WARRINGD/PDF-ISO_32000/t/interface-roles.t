use v6;
use Test;
use ISO_32000::Info;
plan 2;

my role Info-sans-Trapped {
    has $.info handles <Title Author Subject Keywords Creator Producer CreationDate ModDate>;
}

my role Info-all does Info-sans-Trapped {
    method Trapped {'Unknown'}
}

dies-ok { (%() does Info-sans-Trapped).^mixin: ISO_32000::Info}, "interface role missing method - dies";
lives-ok { (%() does Info-all).^mixin: ISO_32000::Info }, "interface role missing method - lives";

