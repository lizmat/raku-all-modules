TITLE
=====

pod-render.pl6

SUBTITLE
========

Program to render Pod documentation

Synopsis
========

    pod-render.pl6 --pdf bin/pod-render.pl6

Usage
=====

    pod-render.pl6 [options] <pod-file>

Arguments
---------

### pod-file

This is the file in which the pod documentation is written and must be rendered.

Options
-------

### --pdf

Generate output in pdf format. Result is placed in current directory or in the `./doc` directory if it exists. Pdf is generated using the program **wkhtmltopdf** so that must be installed.

### --html

Generate output in html format. This is the default. Result is placed in current directory or in the `./doc` directory if it exists.

### --md

Generate output in md format. Result is placed in current directory or in the `./doc` directory if it exists.

### --style=some-prettify-style

This program uses the Google prettify javascript and stylesheets to render the code. The styles are `default`, `desert`, `doxy`, `sons-of-obsidian` and `sunburst`. By default the progam uses, well you guessed it, 'default'. This option is only useful with `--html` and `--pdf`. There is another style which is just plain and simple and not used with the google prettifier. This one is selected using `pod6`.

It is possible to specify one or more of the output format options generating more than one document at once.
