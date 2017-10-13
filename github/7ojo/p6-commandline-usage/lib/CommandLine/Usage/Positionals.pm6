class CommandLine::Usage::Positionals {

    method apply($base, @filter) { 
        my %positionals;
        for $base.func.candidates -> $candidate {
            if @filter.elems > 0 and $candidate.signature.params[0] and $candidate.signature.params[0].constraint_list().elems > 0 {
                for $candidate.signature.params -> $param {
                    my $name = $param.name ?? $param.name !! '';
                    if $param.positional and $name.chars > 0 {
                        %positionals{$param.name} = $param.WHY.Str;
                    }
                }
            } else {
                # TODO: 
            }
        }
        $base.replace:
            POSITIONALS-TEXT => ( %positionals.values.elems > 0 ?? " " ~ %positionals.values.join(' ') !! '' )
            ;
    }
    
}
