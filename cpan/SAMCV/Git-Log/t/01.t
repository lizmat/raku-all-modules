use v6;
use Test;
use Git::Log;
plan 1;
if !".git".IO.d {
    pass "SKIPPED: Not in a git repo. Test only works if module is installed from its git repo";
}
else {
    is-deeply git-log('c32db09f3e6b083f44a816b24ccec7fe6a07a61c', :get-changes), $[{:AuthorDate("2018-08-24T09:00:07-07:00"), :AuthorEmail("samantham\@posteo.net"), :AuthorName("Samantha McVey"), :Body(""), :Subject("Initial version 0.1.0"), :changes($[{:added(16), :filename(".editorconfig"), :removed(0)}, {:added(14), :filename(".gitignore"), :removed(0)}, {:added(9), :filename("CHANGELOG.md"), :removed(0)}, {:added(24), :filename("META6.json"), :removed(0)}, {:added(70), :filename("README.md"), :removed(0)}, {:added(3), :filename("gen-md.sh"), :removed(0)}, {:added(126), :filename("lib/Git/Log.pm6"), :removed(0)}]), :ID("c32db09f3e6b083f44a816b24ccec7fe6a07a61c")},], "Test log for first commit of this repo";
    ;
}
