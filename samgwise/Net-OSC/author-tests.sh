#! /bin/bash
export TEST_AUTHOR=1
prove -re "perl6 -Ilib" t
