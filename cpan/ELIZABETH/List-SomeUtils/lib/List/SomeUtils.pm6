use v6.c;

class List::SomeUtils:ver<0.0.1>:auth<cpan:ELIZABETH> {
    use List::MoreUtils;

    # there's probably a smarter way to do this, but this will do for now
    our constant &after is export(:all) = &List::MoreUtils::after;
    our constant &after_incl is export(:all) = &List::MoreUtils::after_incl;
    our constant &all is export(:all) = &List::MoreUtils::all;
    our constant &all_u is export(:all) = &List::MoreUtils::all_u;
    our constant &any is export(:all) = &List::MoreUtils::any;
    our constant &any_u is export(:all) = &List::MoreUtils::any_u;
    our constant &apply is export(:all) = &List::MoreUtils::apply;
    our constant &arrayify is export(:all) = &List::MoreUtils::arrayify;
    our constant &distinct is export(:all) = &List::MoreUtils::distinct;
    our constant &before is export(:all) = &List::MoreUtils::before;
    our constant &before_incl is export(:all) = &List::MoreUtils::before_incl;
    our constant &binsert is export(:all) = &List::MoreUtils::binsert;
    our constant &bremove is export(:all) = &List::MoreUtils::bremove;
    our constant &bsearch is export(:all) = &List::MoreUtils::bsearch;
    our constant &bsearch_index is export(:all) = &List::MoreUtils::bsearch_index;
    our constant &bsearch_insert is export(:all) = &List::MoreUtils::bsearch_insert;
    our constant &bsearch_remove is export(:all) = &List::MoreUtils::bsearch_remove;
    our constant &bsearchidx is export(:all) = &List::MoreUtils::bsearchidx;
    our constant &duplicates is export(:all) = &List::MoreUtils::duplicates;
    our constant &each_array is export(:all) = &List::MoreUtils::each_array;
    our constant &each_arrayref is export(:all) = &List::MoreUtils::each_arrayref;
    our constant &equal_range is export(:all) = &List::MoreUtils::equal_range;
    our constant &false is export(:all) = &List::MoreUtils::false;
    our constant &first_index is export(:all) = &List::MoreUtils::first_index;
    our constant &first_result is export(:all) = &List::MoreUtils::first_result;
    our constant &first_value is export(:all) = &List::MoreUtils::first_value;
    our constant &firstidx is export(:all) = &List::MoreUtils::firstidx;
    our constant &firstres is export(:all) = &List::MoreUtils::firstres;
    our constant &firstval is export(:all) = &List::MoreUtils::firstval;
    our constant &frequency is export(:all) = &List::MoreUtils::frequency;
    our constant &indexes is export(:all) = &List::MoreUtils::indexes;
    our constant &insert_after is export(:all) = &List::MoreUtils::insert_after;
    our constant &insert_after_string is export(:all) = &List::MoreUtils::insert_after_string;
    our constant &last_index is export(:all) = &List::MoreUtils::last_index;
    our constant &last_result is export(:all) = &List::MoreUtils::last_result;
    our constant &last_value is export(:all) = &List::MoreUtils::last_value;
    our constant &lastidx is export(:all) = &List::MoreUtils::lastidx;
    our constant &lastres is export(:all) = &List::MoreUtils::lastres;
    our constant &lastval is export(:all) = &List::MoreUtils::lastval;
    our constant &listcmp is export(:all) = &List::MoreUtils::listcmp;
    our constant &lower_bound is export(:all) = &List::MoreUtils::lower_bound;
    our constant &mesh is export(:all) = &List::MoreUtils::mesh;
    our constant &minmax is export(:all) = &List::MoreUtils::minmax;
    our constant &minmaxstr is export(:all) = &List::MoreUtils::minmaxstr;
    our constant &mode is export(:all) = &List::MoreUtils::mode;
    our constant &natatime is export(:all) = &List::MoreUtils::natatime;
    our constant &none is export(:all) = &List::MoreUtils::none;
    our constant &none_u is export(:all) = &List::MoreUtils::none_u;
    our constant &notall is export(:all) = &List::MoreUtils::notall;
    our constant &notall_u is export(:all) = &List::MoreUtils::notall_u;
    our constant &nsort_by is export(:all) = &List::MoreUtils::nsort_by;
    our constant &occurrences is export(:all) = &List::MoreUtils::occurrences;
    our constant &one is export(:all) = &List::MoreUtils::one;
    our constant &one_u is export(:all) = &List::MoreUtils::one_u;
    our constant &only_index is export(:all) = &List::MoreUtils::only_index;
    our constant &only_result is export(:all) = &List::MoreUtils::only_result;
    our constant &only_value is export(:all) = &List::MoreUtils::only_value;
    our constant &onlyidx is export(:all) = &List::MoreUtils::onlyidx;
    our constant &onlyres is export(:all) = &List::MoreUtils::onlyres;
    our constant &onlyval is export(:all) = &List::MoreUtils::onlyval;
    our constant &pairwise is export(:all) = &List::MoreUtils::pairwise;
    our constant &part is export(:all) = &List::MoreUtils::part;
    our constant &qsort is export(:all) = &List::MoreUtils::qsort;
    our constant &reduce_0 is export(:all) = &List::MoreUtils::reduce_0;
    our constant &reduce_1 is export(:all) = &List::MoreUtils::reduce_1;
    our constant &reduce_u is export(:all) = &List::MoreUtils::reduce_u;
    our constant &samples is export(:all) = &List::MoreUtils::samples;
    our constant &singleton is export(:all) = &List::MoreUtils::singleton;
    our constant &sort_by is export(:all) = &List::MoreUtils::sort_by;
    our constant &true is export(:all) = &List::MoreUtils::true;
    our constant &uniq is export(:all) = &List::MoreUtils::uniq;
    our constant &upper_bound is export(:all) = &List::MoreUtils::upper_bound;
    our constant &zip is export(:all) = &List::MoreUtils::zip;
    our constant &zip6 is export(:all) = &List::MoreUtils::zip6;
    our constant &zip_unflatten is export(:all) = &List::MoreUtils::zip_unflatten;
}

sub EXPORT(*@args, *%_) {
    if @args {
        my $imports := Map.new( |(EXPORT::all::{ @args.map: '&' ~ * }:p) );
        if $imports != @args {
            die "List::MoreUtils doesn't know how to export: "
              ~ @args.grep( { !$imports{$_} } ).join(', ')
        }
        $imports
    }
    else {
        Map.new
    }
}

=begin pod

=head1 NAME

List::SomeUtils - Port of Perl 5's List::SomeUtils 0.56

=head1 SYNOPSIS

    # import specific functions
    use List::SomeUtils <any uniq>;

    if any { /foo/ }, uniq @has_duplicates {
        # do stuff
    }

    # import everything
    use List::SomeUtils ':all';

=head1 DESCRIPTION

List::SomeUtils is a functional copy of L<List::MoreUtils>.  As for the
reasons of its existence, please check the documentation of the Perl 5
version.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
