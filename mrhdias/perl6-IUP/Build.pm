use Panda::Common;
use Panda::Builder;

my $o  = $*VM<config><o>;
my $so = $*VM<config><load_ext>;
my $name = "IUP";
my $libs = "-Wl,--no-as-needed -liup -liupimglib";

class Build is Panda::Builder {
    method build(Pies::Project $p) {
        my $workdir = $.resources.workdir($p);

		my $c_line = "$*VM<config><cc> -c $*VM<config><cc_shared> $*VM<config><cc_o_out>src/$name$o "
						~ "$*VM<config><ccflags> src/$name.c";
		my $l_line = "$*VM<config><ld> $*VM<config><ld_load_flags> $*VM<config><ldflags> "
						~ "$*VM<config><libs>$libs $*VM<config><ld_out>src/$name$so src/$name$o";
		shell($c_line);
		shell($l_line);
		shell("rm src/$name$o");
		shell("mkdir -p blib/lib");
		shell("cp src/$name$so blib/lib");
    }
}

