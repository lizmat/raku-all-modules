use Test;
use lib $?FILE.IO.parent.child("lib").Str;

plan 15;

multi no-clobber('one') { 'one' };

{
    use push-multi;
    is &foo.candidates.elems,2,"correct candidates";
    is foo('one'),'one',"multi #1 installed";
    is foo('two'),'two',"multi #2 installed";

    ok Numeric === &bar.signature.params[0].type,'proto';
    is bar(Int),'Int','multi #1 installed for custom proto';
    is bar(Num),'Num','multi #2 installed for custom proto';
    is &bar.candidates.elems,2,'correct candidates';

    is baz('one'),'one';
    is baz('two'),'two';

    is non-multi(Int),'Int','non-multis work';
    is non-multi(Num),'Num','non-multis work';

    is no-clobber('one'),'one',"push-lexical didn't clobber";
    is no-clobber('two'),'two',"push-lexical worked";

    is Foo.new{"wee"}, "win",'multi pushing dispatch order works';
}

dies-ok { no-clobber('two') },"push-lexical didn't leak";
