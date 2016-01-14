#!/bin/bash

find ~/.perl6/2015.12/ -mindepth 2 -type f -exec grep -q "AWS::Pricing" {} \; -delete
