class CommandLine::Usage::Header {

    method apply($base) {
        $base.replace:
            USAGE-TEXT => "\nUsage",
            COMMAND-NAME => "\t{$base.name}",
            DESCRIPTION => "\n\n\n{$base.desc}\n\n"
            ;
    }

}
