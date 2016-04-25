unit class Rabble:auth<Jake Russo>:ver<0.3.1>;

use Rabble::Lexicon;
use Rabble::Reader;
use Rabble::Compiler;

has @.stack;

has %!lexicon;
has Rabble::Reader $!reader;
has Rabble::Compiler $!compiler;

has IO::Handle $.in;
has IO::Handle $.out;

submethod BUILD(:$!in = $*IN, :$!out = $*OUT) {
  $!reader .= new :in($!in);
  %!lexicon := Rabble::Lexicon.new(
    context => self,
    modules => [
      (require Rabble::Verbs::Shufflers),
      (require Rabble::Verbs::StackOps),
      (require Rabble::Verbs::IO),
      (require Rabble::Math::Arithmetic),
      (require Rabble::Verbs::Comparators),
      (require Rabble::Verbs::Combinators)
    ]
  );
  $!compiler .= new :context(self) :lexicon(%!lexicon);
  %!lexicon.alias('+', 'plus');
  %!lexicon.alias('*', 'multiply');
  %!lexicon.alias('-', 'subtract');
  %!lexicon.alias('/', 'divide');
  %!lexicon.alias('%', 'modulo');
  %!lexicon.alias('/%', 'ratdiv');

  %!lexicon.alias('=', 'eq');
  %!lexicon.alias('<>', 'noteq');
  %!lexicon.alias('>', 'gt');
  %!lexicon.alias('<', 'lt');

  %!lexicon.alias('.', 'dot');
  %!lexicon.alias('.S', 'dot-s');

  %!lexicon.define :name('bye') :block(&exit);
}

method run(Str $code) { $!reader.parse($code, :actions($!compiler)) }
