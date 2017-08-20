# -*- mode: perl6; -*-
use v6;

use Test;
use App::Miroku::Template;

class TemplateTest {
    has $!author = qx{git config --global user.name}.chomp;
    has $!email  = qx{git config --global user.email}.chomp;
    has $!year   = Date.today.year;

    method test(Str $module-name is copy) {
        plan 2;

        my %contents = App::Miroku::Template::get-template(
            :module($module-name),
            :$!author, :$!email, :$!year,
            dist => $module-name.subst( '::', '-', :g )
        );

        ok %contents;
        is-deeply %contents.keys.sort, <gitignore license module test-case travis>;

    }
    
}


TemplateTest.new.test( 'Hoge::Piyo' );
