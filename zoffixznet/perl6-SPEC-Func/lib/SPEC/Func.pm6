sub EXPORT (*@wanted) {
    my $where-to = try {$*W.current_file} // '<unknown file>';

    @wanted or die "Specify at least one function for SPEC::Func to import into"
        ~ " $where-to. Your choices are {$*SPEC.^methods».name.sort}";

    Map.new: @wanted.unique.map: {
        $*SPEC.^can($^want) or die "SPEC::Func cannot export $want into"
            ~ " $where-to because it's not provided by \$*SPEC";

        "&$want" => sub (|c) { $*SPEC."$want"(|c) };
    }
}
