# walker.t --- test the tree walker

use v6;
use Test;

use Pod::Walker;

my $podblock = Pod::Block::Named.new(
    name => "pod",
    config => ().hash,
    content => Array.new(
        Pod::Block::Named.new(
            name => "TITLE",
            config => ().hash,
            content => Array.new(
                Pod::Block::Para.new(
                    config => ().hash,
                    content => Array.new(
                        "The Great Test"
                    )
                )
            )
        ),
        Pod::Heading.new(
            level => 1,
            config => ().hash,
            content => Array.new(
                Pod::Block::Para.new(
                    config => ().hash,
                    content => Array.new(
                        "Begins"
                    )
                )
            )
        ),
        Pod::Block::Para.new(
            config => ().hash,
            content => Array.new(
                "And ",
                Pod::FormattingCode.new(
                    type => "I",
                    meta => Array.new(),
                    config => ().hash,
                    content => Array.new(
                        "now"
                    )
                ),
                " it ",
                Pod::FormattingCode.new(
                    type => "B",
                    meta => Array.new(),
                    config => ().hash,
                    content => Array.new(
                        "ends"
                    )
                ),
               ". Goodbye."
           )
       )
   )
);

my $output = q:to/EOS/.chomp;
BLOCK[pod][
BLOCK[TITLE][
¶[The Great Test]
]H[1][¶[Begins]]
¶[And {I|now} it {B|ends}. Goodbye.]
]
EOS

sub namedConv(@text, $name) {
    "BLOCK[$name][\n{[~] @text}\n]";
}

sub paraConv(@text) {
    "¶[{[~] @text}]";
}

sub headingConv(@text, $level) {
    "H[$level][{[~] @text}]\n";
}

sub plainConv($text) {
    $text;
}

sub fcodeConv(@text, $type, @meta) {
    "\{$type|{[~] @text}}"
}

my $wc = Walker::Callees.new;
$wc.set-named(&namedConv);
$wc.set-para(&paraConv);
$wc.set-heading(&headingConv);
$wc.set-plain(&plainConv);
$wc.set-fcode(&fcodeConv);

is pod-walk($wc, $podblock), $output, "Tree walked successfully.";