Facter.add(<perl6os>, sub ($f) {
    $f.setcode(block => sub {
        $*OS.Str
    });
})

