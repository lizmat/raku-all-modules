unit module CucumisSextus::Tags;

my grammar TagFilter {
    token tag-atom {
        '@' (<[A..Za..z0..9_.-]>+)
    }
    rule inverted-tag {
        '~' <tag-atom>
    }
    rule tag {
        <tag-atom>
        | <inverted-tag>
    }
    rule or-expression {
        <tag> ',' <filter-expression>
    }
    rule filter-expression {
          <or-expression>
        | <tag>
    }
    rule filter {
        ^ <filter-expression> $
    }
}

my class TagFilterAction {
    method tag-atom($/) {
        my $atom = ~$/[0];
        make sub ($tag) { 
            if $tag eq $atom {
                return 1
            }
            else {
                return 0;
            }
         };
    }
    method inverted-tag($/) {
        my $tag-atom = $<tag-atom>.made;
        make sub ($tag) { 
            my $result = $tag-atom($tag);
            if $result == 1 {
                return -1;
            }
            else {
                return 1;
            }
        };
    }
    method tag($/) {
        if $<tag-atom> {
            make $<tag-atom>.made;
        }
        elsif $<inverted-tag> {
            make $<inverted-tag>.made;
        }
    }
    method or-expression($/) {
        my $left = $<tag>.made;
        my $right = $<filter-expression>.made;
        make sub ($tag) { 
            if $left($tag) == 1 || $right($tag) == 1 {
                return 1;
            }
            if $left($tag) == -1 || $right($tag) == -1 {
                return -1;
            }
            return 0;
        };
    }
    method filter-expression($/) {
        if $<or-expression> {
            make $<or-expression>.made;
        }
        elsif $<tag> {
            make $<tag>.made;
        }
    }
    method filter($/) {
        make $<filter-expression>.made;
    }
}

sub parse-tags($text) is export {
    # XXX we should really use the same grammar
    if $text ~~ m:g/^\s*('@'(<[A..Za..z0..9_.-]>+)\s*)+$/ {
        my @tags = $0[0]>>[0]>>.Str.sort;
        return @tags;
    }
    return [];
}

sub parse-filter($text) is export {
    my $ret = TagFilter.parse($text, rule => 'filter', actions => TagFilterAction.new);
    if $ret {
        return $ret.made;
    }
    # XXX better exception
    die;
}

sub filter-matches($filter, @tags) is export {
    my $ret = False;
    for @tags -> $tag {
        my $result = $filter($tag);
        if $result == -1 {
            return False;
        }
        elsif $result == 1 {
            $ret = True;
        }
    }
    return $ret;
}

sub all-filters-match(@filters, @tags) is export {
    for @filters -> $filter {
        my $ret = False;
        for @tags -> $tag {
            my $result = $filter($tag);
            if $result == -1 {
                return False;
            }
            elsif $result == 1 {
                $ret = True;
            }
        }
        if !$ret {
            return False;
        }
    }
    return True;
}
