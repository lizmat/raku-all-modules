use LibraryMake;
my %vars = LibraryMake::get-vars('');
my $o  = %vars<O>;
my $so = %vars<SO>;
my $cc = %vars<CC>;
my $ccshared = %vars<CCSHARED>;
my $ccout = %vars<CCOUT>;
my $ccflags = %vars<CCFLAGS>;
my $ld = %vars<LD>;
my $ldshared = %vars<LDSHARED>;
my $ldflags = %vars<LDFLAGS>;
my $ldout = %vars<LDOUT>;
my $libs = %vars<LIBS>;
my $name = "IUP";
my $lib-opts = "-Wl,--no-as-needed -liup -liupimglib";

class Build {
    method build(|) {
		my $c_line = "$cc -c $ccshared {$ccout}src/$name$o "
						~ "$ccflags src/$name.c -I/usr/include/iup";
		my $l_line = "$ld $ldshared $ldflags "
						~ "$libs $lib-opts {$ldout}src/$name$so src/$name$o -I/usr/include/iup";
		shell($c_line);
		shell($l_line);
		shell("rm src/$name$o");
		shell("mkdir -p resources/lib");
		shell("cp src/$name$so resources/lib");
    shell("rm src/$name$so");
    }
}
