use ForeignGrammar;
unit grammar TOML::Grammar;
grammar Value {...}

token ws { [<[\ \t]>|'#'\N*]* }

class AoH is Array {
    method AT-KEY    ($key)          is rw { self[*-1]{$key} }
    method ASSIGN-KEY($key, \assign) is rw { self[*-1]{$key} = assign }
    method BIND-KEY  ($key, \bind)   is rw { self[*-1]{$key} := bind }
}

rule TOP {
    :my %top;
    # The semantics of when it's ok and not okay to used some keyname are
    # rather complicated.
    # For example, "[a.b]\nc = 42" prevents [a.b.c] from being used, but
    # "[a.b.c]\n[a]" is legal.
    :my Bool %used_names;
    # Array-tables depend on redeclaration, so we have to watch them too
    :my Bool %array_names;
    ^ \n *
    [[
    | <keyvalue>
      { given @<keyvalue>[*-1].ast {
        die "Name {.key.join('.')} already in use." if %used_names{~.key}++;
        %top{.key} := .value;
      } }
    | <table>
      { given @<table>[*-1].ast {
        die "Name {.key.join('.')} already in use." if %used_names{~.key}++;
        # Implicit declarations mean that %top{.key} might already be defined,
        # so we include that in the new hash
        %top{.key} := $%(%top{.key}.flatmap({.pairs}), .value.pairs);
        # All of the new sub-keys are considered used in addition to .key
        for .value.keys { %used_names{.key~" $^subkey"}++ };
      } }
    | <table_array>
      { given @<table_array>[*-1].ast {
        if not %array_names{~.key}++ {
            die "Name {.key.join('.')} is not a table-array."
                if %used_names{~.key}++ or %top{.key,}.flat[0];
        }
        # Just pushing to an AoH will sometimes make a normal Array instead of
        # an AoH, so we just make a new AoH each time (for now)
        %top{.key} := AoH.new(|@(%top{.key,}.flat[0]), .value).item;
      } }
    ] \n * ]*
    [ $ || { die "Couldn't parse TOML: $/" } ]
    { make $%top }
}

token key {
    [ <[A..Za..z0..9_-]>+ | <?before \"<-["]> ><str=.Value::string> ]
    { make $<str> ?? $<str>.ast !! ~$/ }
}

token value {
    <val=.Value::value> { make $<val>.ast }
}

rule keyvalue {
    <key> '=' <value>
    { make $<key>.ast => $<value>.ast }
}

rule table {
    '[' ~ ']' <key>+ % \. \n?
    <keyvalue> *
    {
        my %table;
        %table{.key} = .value for @<keyvalue>».ast;
        make lol(|@<key>.map({.ast})) => %table;
    }
}

rule table_array {
    '[[' ~ ']]' <key>+ % \. \n
    <keyvalue> *
    {
        my %table;
        %table{.key} = .value for @<keyvalue>».ast;
        make lol(|@<key>.map({.ast})) => %table;
    }
}

grammar Value does ForeignGrammar {
    token ws { [\n|' '|\t|'#'\N*]* }
    sub process-val($type, $value) {
        state $stringify-types = <datetime bool integer float>.Set;
        $*JSON_COMPAT
            ?? { type => $type, value => $type (elem) $stringify-types ?? ~$value !! $value.ast }
            !! $value.ast
    }
    rule value {
        # Could perhaps be simplified with :dba?
        [
        | <integer>
        | <float>
        | <array>
        | <bool>
        | <datetime>
        | <string>
        ]
        {
            make process-val(|%().kv);
        }
    }

    token integer { <[+-]>? \d+ { make +$/ } }
    token float { <[+-]>? \d+ [\.\d+]? [<[Ee]> <integer>]? { make +$/ }}
    rule array {
        # Arrays are only allowed to contain a single type
        :my $type;
        :my $values;
        \[ ~ \] [
          (
          | <integer>  * %% \,
          | <float>    * %% \,
          | <array>    * %% \,
          | <bool>     * %% \,
          | <datetime> * %% \,
          | <string>   * %% \,
          )
          { ($type, $values) = %0.pairs.first({.value}).kv }
          [ <value> { die "Can't use value of type "~ %<value>.keys[0].tc ~" in an array of type "~$type.tc }
          ]?
        ]
        { make map {process-val($type, $_)}, @$values }
    }
    token bool {
        | true { make True }
        | false { make False }
    }

    token datetime {
        (\d**4) '-' (\d\d) '-' (\d\d)
        <[Tt]>
        (\d\d) ':' (\d\d) ':' (\d\d ['.' \d+]?)
        [
        | <[Zz]>
        | (<[+-]> \d\d) ':' (\d\d)
        ]
        {
            make DateTime.new: |%(
                <year month day hour minute second> Z=> map +*, @()
                :timezone( $6 ?? (($6*60 + $7) * 60).Int !! 0 )
            )
        }
    }

    proto token string { * }
    # proto token string { {*} { make $<call-rule>.ast } }

    grammar String {
        token stopper { \' }
        token string { <chars>* {make @<chars>.map({.ast}).join}}
        proto token chars { * }
        token chars:non-control { <-[\x00..\x1F\\]-stopper>+ {make ~$/}}
        token chars:escape { \\ {make '\\'}}
    }

    role Escapes {
        token chars:escape {
            \\ [ <escape> || . { die "Found bad escape sequence $/" } ]
            {make $<escape>.ast}
        }
        proto token escape { * }
        token escape:sym<b> { <sym> {make "\b"}}
        token escape:sym<t> { <sym> {make "\t"}}
        token escape:sym<n> { <sym> {make "\n"}}
        token escape:sym<f> { <sym> {make "\f"}}
        token escape:sym<r> { <sym> {make "\r"}}
        token escape:backslash { \\ {make '\\'}}
        token escape:stopper { <stopper> {make ~$/}}
        token hex { <[0..9A..F]> }
        token escape:sym<u> { <sym> <hex>**4 {make chr :16(@<hex>.join)}}
        token escape:sym<U> { <sym> <hex>**8 {make chr :16(@<hex>.join)}}
    }

    role Multi {
        token chars:newline { \n+ {make ~$/}}
        token escape:newline { \n\s* {make ""}}
    }

    token string:sym<'> {
        <sym> ~ <sym> <foreign-rule=.String::string>
        { make $<foreign-rule>.ast }
    }
    token string:sym<'''> {
        [<sym>\n?] ~ <sym>
        <foreign-rule: 'string', state$= String but role :: does Multi {
                token stopper { "'''" }
        }>
        { make $<foreign-rule>.ast }
    }
    token string:sym<"> {
        <sym> ~ <sym>
        <foreign-rule: 'string', state$= String but role :: does Escapes {
                token stopper { \" }
        }>
        { make $<foreign-rule>.ast }
    }
    token string:sym<"""> {
        [<sym>\n?] ~ <sym>
        <foreign-rule: 'string', state$= String but role :: does Escapes does Multi {
            token stopper { '"""' }
        }>
        { make $<foreign-rule>.ast }
    }
}
