use lib <lib>;
use Temp::Path;

with make-temp-path {
        .spurt: 'meows';
    say .slurp: :bin; # OUTPUT: «Buf[uint8]:0x<6d 65 6f 77 73>␤»
    say .absolute;    # OUTPUT: «/tmp/1E508EE56B7C069B7ABB7C71F2DE0A3CE40C20A1398B45535AF3694E39199E9A␤»
}

with make-temp-path :content<meows> :chmod<423> {
    .slurp.say; # OUTPUT: «meows␤»
    .mode .say; # OUTPUT: «0647␤»
}

with make-temp-dir {
    .add('meows').spurt: 'I ♥ Perl 6!';
    .dir.say; # OUTPUT: «("/tmp/B42F3C9D8B6A0C5C911EE24DD93DD213F1CE1DD0239263AC3A7D29A2073621A5/meows".IO)␤»
}

{
    temp $*TMPDIR = make-temp-dir :chmod<700>;
    $*TMPDIR.say;
    # OUTPUT:
    # "/tmp/F5AA112627DA7B59C038900A3C8C7CB05477DCCCEADF2DC447EC304017A1009E".IO
    say make-temp-path;
    # OUTPUT:
    # "/tmp/F5AA112627DA7B59C038900A3C8C7CB05477DCCCEADF2DC447EC304017A1009E/…
    # …C41E7114DD24C65C6722981F8C5693E762EBC5958238E23F7B324A1BDD37A541".IO
}
