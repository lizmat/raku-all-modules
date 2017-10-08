#!/bin/sh

# this is my 1-minute-hacky version of this task

find | grep tzdata\/ | grep -v README | grep -v VERSION | xargs -I '{}' ./gen-tzdata-classes.pl6 '{}' ../lib/DateTime/TimeZone/Zone/
