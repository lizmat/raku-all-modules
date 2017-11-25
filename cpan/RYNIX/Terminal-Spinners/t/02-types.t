#!/usr/bin/env perl6
use v6.c;
use Test;
use Terminal::Spinners;

plan 12;

my @classic     = <| / - \\>;
my @bounce      = ('[=   ]', '[==  ]', '[=== ]', '[ ===]', '[  ==]',
                   '[   =]', '[    ]', '[   =]', '[  ==]', '[ ===]',
                   '[====]', '[=== ]', '[==  ]', '[=   ]', '[    ]');
my @bounce2     = ('( ●    )', '(  ●   )', '(   ●  )', '(    ● )',
                   '(     ●)', '(    ● )', '(   ●  )', '(  ●   )',
                   '( ●    )', '(●     )');
my @dots        = <⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏>;
my @dots2       = <⢄ ⢂ ⢁ ⡁ ⡈ ⡐ ⡠>;
my @dots3       = <⠈ ⠐ ⠠ ⢀ ⡀ ⠄ ⠂ ⠁>;
my @three-dots  = <<'.  ' '.. ' '...'>>;
my @three-dots2 = <<'.  ' '.. ' '...' ' ..' '  .' '   '>>;
my @bar         = <<▁  ▃  ▄  ▅  ▆  ▇  ▆  ▅  ▄  ▃  ▁  ' '>>;
my @bar2        = <<▏  ▎  ▍  ▌  ▊  ▉  ▊  ▋  ▌  ▍  ▎  ' '>>;

my @atypes = (@classic, @bounce, @bounce2, @dots, @dots2, @dots3, @three-dots, @three-dots2, @bar, @bar2);
my @types = <classic bounce bounce2 dots dots2 dots3 three-dots three-dots2 bar bar2>;

my class OutputCapture {
    # credit M. Lenz, Perl 6 Fundamentals
    has @!lines;
    method print(\s) {
        @!lines.push(s);
    }
    method captured() {
    @!lines.join;
    }
}

for ^10 {
    my $output = do {
        my $*OUT = OutputCapture.new;
        my $spinner = Spinner.new: type => @types[$_];
        $spinner.next;
        $*OUT.captured;
    }
    my $match = "\b" x @atypes[$_][0].chars ~ @atypes[$_][0];
    is $output, $match, @types[$_];
}

my $hash-output = do {
    my $*OUT = OutputCapture.new;
    my $hash-bar = Bar.new: type => 'hash';
    $hash-bar.show: 100e0;
    $*OUT.captured;
}

my $equals-output = do {
    my $*OUT = OutputCapture.new;
    my $equals-bar = Bar.new: type => 'hash';
    $equals-bar.show: 100e0;
    $*OUT.captured;
}

is $hash-output.chars, 160, 'hash';
is $equals-output.chars, 160, 'equals';
