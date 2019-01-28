# Igo

An expedient CPAN uploader for Perl 6

## Synopsis

	igo create-layout [--directory=.]
    igo create-archive  [--directory=.]
    igo upload --user=<user> --password=<password>  [--directory=.]

## Description

This provides a simple way to upload Perl 6 modules to CPAN.  

I made it because I found that other things either took over the whole
workflow, or didn't do enough.

So all this does is create a tarball of the files in the distribution,
using the name and version specified in the META6 file and then uploads
it to PAUSE with the credentials specified.

The way this works is that the first time it runs it creates an
[Oyatul](https://github.com/jonathanstowe/Oyatul) layout specification
in your distribution's directory as ```.layout``` this will contain all
of the files found in the directory which don't begin with a '.', now
if you're anything like me you may have your working directory littered
with test files and backups and so forth so you may want to edit this file
before creating the archive, this can be achieved by running

```
igo create-layout
```

When you have all the files that you want to release and then edit 
the ```.layout``` as required (it's JSON and quite obvious,) to remove
extraneous files (or, if you want to distribute dot files that didn't get
added for instance add them.)

If you want to check that you really have all the files you need in the
archive that would be uploaded then you can run

```
igo create-archive
```

and inspect and test as you see fit.

When you are all happy with what you are going to upload then you just
do

```
igo upload --username=<PAUSE username> --password=<PAUSE password>
```

Which will create the archive and upload it with the credentials supplied.

If you don't want to continuously type the credentials at the command line
you can create the file ```$HOME/.config/igo/pause.ini``` with :

```
user <username>
password <password>
```

If you are unhappy with having your password in plaintext then 
[CPAN::Uploader::Tiny](https://github.com/Leont/cpan-upload-tiny) does
support encrypted files, but you can work that our for yourself.


Please feel free to use the ```Igo``` module in your own code, but
it isn't well documented for the time being.

## Installation

This uses [Archive::LibArchive](https://modules.perl6.org/dist/Archive::Libarchive:cpan:FRITH) to make the tarball to upload, so you will need to have ```libarchive``` installed, either via your platform's package manager or by some other means.  I don't know if it is available for Windows.

Assuming you have a working perl6 installation you should be able to
install this with *zef* :

    # From the source directory

    zef install .

    # Remote installation

    zef install Igo

## Support

Suggestions and patches that may make this more useful in your software
are welcomed via github at

https://github.com/jonathanstowe/Igo/issues

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution.

© Jonathan Stowe 2019

