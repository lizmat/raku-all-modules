my $*SPEC = IO::Spec::Unix;
my @resources = sort do gather 'resources'.IO.&(sub recur($_) {
    when .f { take .substr(10).perl }
    when .d { .&recur for .dir }
});

spurt 'lib/TinyCC/Resources/Win64.pm', qq:to/EOF/.encode;
BEGIN \{
    my \\PREFIX = \$*VM.config<prefix>.IO;
    { join "\n    ", @resources.map({
        "\%?RESOURCES\{$_}.copy(.parent.mkdir.child(.basename)) given PREFIX.child($_);"
    }) }
}
EOF

spurt 'META6.json', qq:to/EOF/.encode;
\{
    "name"          : "TinyCC::Resources::Win64",
    "version"       : "0.2",
    "perl"          : "6.c",
    "author"        : "github:cygx",
    "license"       : "LGPL-2.1",
    "description"   : "Win64 build of the Tiny C Compiler",
    "repo-type"     : "git",
    "source-url"    : "git://github.com/cygx/p6-tinycc-resources-win64.git",
    "support"       : \{
        "bugtracker"    : "https://github.com/cygx/p6-tinycc-resources-win64/issues",
        "source"        : "https://github.com/cygx/p6-tinycc-resources-win64"
    },
    "depends"       : [ ],
    "provides"      : \{
        "TinyCC::Resources::Win64"      : "lib/TinyCC/Resources/Win64.pm",
        "TinyCC::Resources::Win64::DLL" : "lib/TinyCC/Resources/Win64/DLL.pm"
    },
    "resources"     : [
        { @resources.join(",\n        ") }
    ]
}
EOF
