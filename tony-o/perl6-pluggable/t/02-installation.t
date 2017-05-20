#!/usr/bin/env perl6

use Pluggable; 
use Test;

plan 1;

# load a class from a proper installation, rather than the filesystem
# this relies on the module in question being installed, which seems ok
# since it is a dependency of Task::Star
class SVGPlotters does Pluggable {
    has @.expected = [
            'SVG::Plot::Pie',
        ];

    method test() {
        my @plugins = @( $.plugins(:base('SVG'), :plugins-namespace('Plot'), :name-matcher(/Pie/)) );
        ok @plugins.map({ .WHAT.perl }).sort eqv @.expected.sort;
    }
};
SVGPlotters.new.test;

