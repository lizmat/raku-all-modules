#!/usr/bin/env perl6
use lib 'lib';
use Test;
use File::Directory::Tree;

constant REP = 't/tmp/ref';
constant DOC = 't/tmp/doc';
constant INDEX = REP ~ '/file-index.json';

plan 9;

#--MARKER-- Test 1
use-ok 'Pod::To::Cached';

use Pod::To::Cached;

if 't/tmp'.IO ~~ :d  {
    empty-directory 't/tmp';
}
else {
    mktree 't/tmp'
}

my Pod::To::Cached $cache;

mktree REP;

#--MARKER-- Test 2
throws-like { $cache .= new(:source( DOC ), :path(REP)) },
    Exception, :message(/'has corrupt doc-cache'/), 'Detects absence of index file';

INDEX.IO.spurt(q:to/CONTENT/);
    {
        "frozen": "True",
        files: { "one": "ONE", "two": "TWO" }
    }
CONTENT

#--MARKER-- Test 3
throws-like { $cache .= new(:source( DOC ), :path( REP )) },
    Exception, :message(/'Configuration failed'/), 'Bad JSON in index file';

INDEX.IO.spurt(q:to/CONTENT/);
        {
            "frozen": "True",
            "files": [ "one", "ONE", "two", "TWO" ],
            "source": "SOURCE"
        }
    CONTENT
#--MARKER-- Test 4
throws-like { $cache .= new(:source( DOC ), :path( REP )) },
    Exception, :message(/'Invalid index file'/), 'Files not hash';

INDEX.IO.spurt(q:to/CONTENT/);
        {
            "files": { "one": "ONE", "two": "TWO" },
            "source": "SOURCE"
        }
    CONTENT
#--MARKER-- Test 5
throws-like { $cache .= new(:source( DOC ), :path( REP )) },
    Exception, :message(/'Invalid index file'/), 'No frozen';

INDEX.IO.spurt(q:to/CONTENT/);
        {
            "frozen": "True",
            "source": "SOURCE"
        }
    CONTENT
#--MARKER-- Test 6
throws-like { $cache .= new(:source( DOC ), :path( REP )) },
    Exception, :message(/'Invalid index file'/), 'No files';

INDEX.IO.spurt(q:to/CONTENT/);
        {
            "frozen": "False",
            "files": {
                "one": {
                    "cache-key": "ONE",
                    "added": 10,
                    "path": "some/path",
                    "status": "Valid"
                },
                 "two": {
                     "cache-key": "TWO",
                     "added": 10,
                     "path": "some/path",
                     "status": "Valid"
                 }
             }
        }
    CONTENT
#--MARKER-- Test 7
throws-like { $cache .= new(:source( DOC ), :path( REP )) },
    Exception, :message(/'Invalid index file'/), 'No source without frozen';

INDEX.IO.spurt(q:to/CONTENT/);
        {
            "frozen": "False",
            "files": {
                "one": {
                    "cache-key": "ONE",
                    "added": 10,
                    "path": "some/path",
                    "status": "Valid"
                },
                 "two": {
                     "cache-key": "TWO",
                     "added": 10,
                     "path": "some/path",
                     "status": "Valid"
                 }
             },
            "source": "t/tmp/doc"
        }
    CONTENT
#--MARKER-- Test 8
throws-like { $cache .= new(:source( DOC ), :path( REP )) },
    Exception, :message(/'Source verification failed'/), 'No source directory at source in index';

# TODO source-verify with frozen cache
rmtree REP ;

#--MARKER-- Test 9
throws-like { $cache .= new(:source( DOC ), :path( REP )) },
    Exception, :message(/'is not a directory'/), 'Detects absence of source directory';