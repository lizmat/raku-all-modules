use v6;
use Powerline::Prompt;

class Powerline::Prompt::Shell::Bash is Powerline::Prompt {

    has Str $.user = ' \\u ';
    has Str $.host = ' \\h ';
    has Str $.root = ' \\$ ';

}
