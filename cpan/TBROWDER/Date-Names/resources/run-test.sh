#!/bin/bash

TESTS=$(ls 0*.t)

for f in ${TESTS} ; do
    perl6 -I../lib  $f ;
done
