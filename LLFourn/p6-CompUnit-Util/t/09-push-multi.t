use Test;
use lib $?FILE.IO.parent.child("lib").Str;

plan 15;


{
    use CompUnit::Util :push-multi;
    multi foo('one') { 'one' }
    multi foo('two') { 'two' }

    &foo.&push-multi(sub ('three') { "three"});

    is foo('two'),'two',"push-multi runtime doesn't clobber";
    is foo('three'),'three','push-multi runtime works';
}

multi no-clobber('one') { 'one' };

{
    use push-multi;
    is &foo.candidates.elems,2,"correct candidates";
    is foo('one'),'one',"multi #1 installed";
    is foo('two'),'two',"multi #2 installed";

    ok Numeric === &bar.signature.params[0].type,'proto';
    is bar(Int),'barInt','multi #1 installed for custom proto';
    is bar(Num),'barNum','multi #2 installed for custom proto';
    is &bar.candidates.elems,2,'correct candidates';

    is baz('one'),'bazone';
    is baz('two'),'baztwo';

    # is non-multi(Int),'nmInt','non-multis work';
    # is non-multi(Num),'nmNum','non-multis work';
    # eval-dies-ok q|non-multi(Str)|,"subsequent call to push multi isn't there";
    # is non-multi2(Str),'nm2Str','second non-multi works';

    is no-clobber('one'),'one',"push-lexical didn't clobber";
    is no-clobber('two'),'two',"push-lexical worked";

    is Foo.new{"wee"}, "win",'multi pushing dispatch order works';
}

dies-ok { no-clobber('two') },"push-lexical didn't leak";
