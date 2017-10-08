use lib <lib>;
use Testo;
use Temp::Path;
use IO::CatHandle::AutoLines;

plan 10;

sub term:<make-cat> (:&on-switch) {
    state @files = ("a\nb\nc", "d\ne\nf", "g\nh")
        .map: { make-temp-path :content($_) }

    IO::CatHandle.new: |(:&on-switch with &on-switch), @files
}

group 'no parametarization' => 2 => {
    my $cat = make-cat does IO::CatHandle::AutoLines;
    is $cat.ln, 0, 'ln is 0 before start';
    my @res = $cat.lines.map: { $_, $cat.ln<> }
    is @res, [
        ('a', 1), ('b', 2), ('c', 3),
        ('d', 1), ('e', 2), ('f', 3),
        ('g', 1), ('h', 2),
    ]
}

group 'false reset parametarization' => 2 => {
    my $cat = make-cat does IO::CatHandle::AutoLines[:!reset];
    is $cat.ln, 0, 'ln is 0 before start';
    my @res = $cat.lines.map: { $_, $cat.ln<> }
    is @res, [
        ('a', 1), ('b', 2), ('c', 3),
        ('d', 4), ('e', 5), ('f', 6),
        ('g', 7), ('h', 8),
    ]
}

group 'true reset parametarization' => 2 => {
    my $cat = make-cat does IO::CatHandle::AutoLines[:reset];
    is $cat.ln, 0, 'ln is 0 before start';
    my @res = $cat.lines.map: { $_, $cat.ln<> }
    is @res, [
        ('a', 1), ('b', 2), ('c', 3),
        ('d', 1), ('e', 2), ('f', 3),
        ('g', 1), ('h', 2),
    ]
}

group 'can still set on-switch on instantiation (no reset)' => 3 => {
    my $pass;
    my $cat = (make-cat :on-switch{ $pass++ })
        does IO::CatHandle::AutoLines[:!reset];
    is $cat.ln, 0, 'ln is 0 before start';
    my @res = $cat.lines.map: { $_, $cat.ln<> }
    is @res, [
        ('a', 1), ('b', 2), ('c', 3),
        ('d', 4), ('e', 5), ('f', 6),
        ('g', 7), ('h', 8),
    ];
    is $pass, 4, 'custom on-switch triggered';
}

group 'can still set on-switch on instantiation (reset)' => 3 => {
    my $pass;
    my $cat = (make-cat :on-switch{ $pass++ })
        does IO::CatHandle::AutoLines[:reset];
    is $cat.ln, 0, 'ln is 0 before start';
    my @res = $cat.lines.map: { $_, $cat.ln<> }
    is @res, [
        ('a', 1), ('b', 2), ('c', 3),
        ('d', 1), ('e', 2), ('f', 3),
        ('g', 1), ('h', 2),
    ];
    is $pass, 4, 'custom on-switch triggered';
}

group 'can still set on-switch past instantiation (no reset)' => 3 => {
    my $pass;
    my $cat = make-cat does IO::CatHandle::AutoLines[:!reset];
    is $cat.ln, 0, 'ln is 0 before start';
    $cat.on-switch = { $pass++ };
    my @res = $cat.lines.map: { $_, $cat.ln<> }
    is @res, [
        ('a', 1), ('b', 2), ('c', 3),
        ('d', 4), ('e', 5), ('f', 6),
        ('g', 7), ('h', 8),
    ];
    is $pass, 3, 'custom on-switch triggered';
}

group 'can still set on-switch past instantiation (reset)' => 3 => {
    my $pass;
    my $cat = make-cat does IO::CatHandle::AutoLines;
    is $cat.ln, 0, 'ln is 0 before start';
    $cat.on-switch = { $pass++ };
    my @res = $cat.lines.map: { $_, $cat.ln<> }
    is @res, [
        ('a', 1), ('b', 2), ('c', 3),
        ('d', 1), ('e', 2), ('f', 3),
        ('g', 1), ('h', 2),
    ];
    is $pass, 3, 'custom on-switch triggered';
}

group '.get works (no reset)' => 3 => {
    my $pass;
    my $cat = make-cat does IO::CatHandle::AutoLines[:!reset];
    is $cat.ln, 0, 'ln is 0 before start';
    $cat.on-switch = { $pass++ };
    my @res = do while ($_ := $cat.get) !=== Nil { $_, $cat.ln<> }
    is @res, [
        ('a', 1), ('b', 2), ('c', 3),
        ('d', 4), ('e', 5), ('f', 6),
        ('g', 7), ('h', 8),
    ];
    is $pass, 3, 'custom on-switch triggered';
}

group 'can still set on-switch past instantiation (reset)' => 3 => {
    my $pass;
    my $cat = make-cat does IO::CatHandle::AutoLines;
    is $cat.ln, 0, 'ln is 0 before start';
    $cat.on-switch = { $pass++ };
    my @res = do while ($_ := $cat.get) !=== Nil { $_, $cat.ln<> }
    is @res, [
        ('a', 1), ('b', 2), ('c', 3),
        ('d', 1), ('e', 2), ('f', 3),
        ('g', 1), ('h', 2),
    ];
    is $pass, 3, 'custom on-switch triggered';
}

is-run $*EXECUTABLE, :args[
    '-Ilib', |('-I' «~« $*REPO.repo-chain.map: *.path-spec), '-e', ｢
        use IO::CatHandle::AutoLines;
        42 does IO::CatHandle::AutoLines;
    ｣,
], :err(/"IO::CatHandle::AutoLines can only be mixed into an IO::CatHandle"/),
   'trying to mix into wrong object';
