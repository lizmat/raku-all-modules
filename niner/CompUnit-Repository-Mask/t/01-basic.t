use v6.c;
use Test;
use CompUnit::Repository::Mask :mask-module, :unmask-module;

mask-module('NativeCall');
throws-like(
    { require NativeCall },
    X::CompUnit::UnsatisfiedDependency,
    'NativeCall unavailable after getting masked',
);

unmask-module('NativeCall');
require NativeCall;
pass('NativeCall found after being unmasked');

done-testing;
