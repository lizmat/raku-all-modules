#!/bin/bash

#
# Copyright (C) 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    for i in *.txt ; do
        NEW=$( echo "$i" | sed -e 's/\.txt$/.msg/' )
        perl6 ../bin/make-message.pl6 <$i >$NEW
    done
}

doit "$@"


