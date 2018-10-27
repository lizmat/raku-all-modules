use Test;
use CompUnit::Util :capture-import;
use lib $?FILE.IO.parent.child("lib").Str;
need exports-stuff;

plan 17;

{
    ok $_ = capture-import('exports-stuff');
    ok .<&foo>.(), 'foo captured';
    ok .<&baz>.(), 'baz captured';
    nok .<&derp>, 'derp not captured';
    nok .<&opt> , 'opt not captured';
    ok .<&bar>.(), 'bar from sub EXPORT captured';
}

{
    $_ = capture-import('exports-stuff', :rob-schnider);
    ok .<&derp>.(), 'derp captured';
    ok .<&herp>.(), 'herp captured';
    nok .<&foo>, 'foo not captured';
}

{
    $_ = capture-import('exports-stuff', :rob-schnider,:DEFAULT);
    ok .<&derp>.(), 'derp captured';
    ok .<&herp>.(), 'herp captured';
    ok .<&foo>.(), 'foo captured';
    ok .<&baz>.(), 'baz captured';
}

{
    $_ = capture-import('exports-stuff', True, :rob-schnider);
    ok .<&bar>.(), 'bar still works';
    ok .<&opt>.(), 'passed positional made opt work';
    nok .<&foo>,   'positional disabled DEFAULT';
    ok .<&derp>.(),'positional + tag';
}
