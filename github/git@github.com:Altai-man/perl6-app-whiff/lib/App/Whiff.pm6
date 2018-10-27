use v6;

unit module App::Whiff;

use File::Which;

our sub find-first(@commands) is export {
    my $file;
    for @commands -> $name {
	return $name if $name ~~ m{^\/} && $name.IO ~~ :x;
	$file = which($name);
	return $file if $file.defined;
    }
    False;
}

our sub run() is export {
    die "usage: whiff <command ...>\n" unless @*ARGS;
    my $file = find-first([@*ARGS]);
    die "no alternative found\n" unless $file;
    say "$file";
}

our sub whiff(@commands) is export {
    find-first @commands;
}
