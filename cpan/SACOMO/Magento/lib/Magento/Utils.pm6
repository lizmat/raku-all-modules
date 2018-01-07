use v6;

unit module Magento::Utils;

subset StrInt of Any where Str|Int;

proto sub search-criteria-to-query-string(|) is export {*}
multi sub search-criteria-to-query-string(
    StrInt $data,
    Str    $parent,
    Int    :$filtergroup_i,
    Int    :$filters_i
    --> Str
) {
    "{$parent}]={$data}";
}

multi sub search-criteria-to-query-string(
    Pair $data,
    Str  $parent,
    Int  :$filtergroup_i,
    Int  :$filters_i
    --> Str
) {
    "[{$data.key}]={$data.value}"; 
}

multi sub search-criteria-to-query-string(
    Iterable $data,
    Str      $parent,
    Int      :$filtergroup_i is copy,
    Int      :$filters_i is copy
    --> Str
) {
    (map -> $v {
        my $segment = search-criteria-to-query-string $v, $parent, :$filtergroup_i, :$filters_i;
        ++$filters_i;
        # Only increment when we progress to the next filterGroup
        ++$filtergroup_i when $v.values[0][0].keys.any ~~ 'field'|'value'|'condition_type';
        $segment;
    }, @$data).join('&');
}

multi sub search-criteria-to-query-string(
    Hash $data,
    Str  $parent,
    Int  :$filtergroup_i is copy,
    Int  :$filters_i is copy
    --> Str
) {

    (map -> $k, $v {
        my $prefix = do given $parent {
            when 'filters' {
                "searchCriteria[filterGroups][$filtergroup_i][filters][$filters_i][";
            }
            when 'searchCriteria' {
                $v ~~ Array ?? "" !! "{$parent}[";
            }
            when 'filterGroups' {
                $filters_i = 0;
                ''
            }
            default {
                "{$parent}][$filters_i][";
            }
        }
        $prefix ~ search-criteria-to-query-string($v, $k, :$filtergroup_i, :$filters_i);
    }, kv $data).join('&');
}

multi sub search-criteria-to-query-string(
    Hash $data,
    Int  $filtergroup_i = 0,
    Int  $filters_i     = 0
    --> Str
) {
    (map -> $k, $v {
        search-criteria-to-query-string($v, $k, :$filtergroup_i, :$filters_i);
    }, kv $data).head;
}

multi sub search-criteria-to-query-string(
    Hash $data where $data ~~ Empty
) {
    'searchCriteria';
}


sub build-filter(
    @parts
    --> Hash
) {
    %{
        field          => @parts[0],
        value          => @parts[1],
        condition_type => @parts[2]
    }
}

sub search-criteria-hash(
    @filters,
    :$conditions
) {
    searchCriteria => %{
        filterGroups => [
            {
                filters => [ @filters ]
            },
        ],
        |$conditions
    }
}

sub nested-filters(
    @set
    --> Seq
) {
    do gather @set.map: -> $set {
        take build-filter($set) when $set.all ~~ Str; 
        take nested-filters($set) when $set.all !~~ Str;
    }
}

our sub search-critera(
    Array $filters,
    :$conditions = %{}
    --> Hash
) is export {

    # Single set of filters
    return %( 
        search-criteria-hash [ build-filter($filters), ], :$conditions
    ) when $filters.all ~~ Str;

    # Multiple AND / OR filters
    return %(
        search-criteria-hash nested-filters($filters), :$conditions
    );
}

sub tokenize(
    Str $str
) is export {
    join '', grep {$_ !~~ /^':'/}, split '/', $str ~~ m/ [\S* \s* '/V1/'] <(\S*)> /;
}

