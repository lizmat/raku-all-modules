use v6;

=head1 TITLE
Native::Resources
=head1 ABSTRACT
Boilerplate helper for bundling native code
=head1 AUTHOR
Rob Hoelz
=head1 SYNOPSIS
=begin code
    # assume you're building a helper library named 'helper'

    # in Build.pm at the root of your distribution
    use Panda::Builder;
    use Native::Resources::Build;

    class Build is Panda::Builder {
        method build($workdir) {
            make($workdir, "$workdir/resources/lib", :libname<helper>);
        }
    }

    # in Makefile.in
    all: resources/lib/libhelper%SO% %FAKESO%

    # rest of Makefile rules

    # in META.info
    {
        ...other metadata...
        "resources": [
            "lib/libhelper.so",
            "lib/libhelper.dll",
            "lib/libhelper.dylib"
        ],
    }

    # in lib/Helper.pm (or whatever your module is called)
    use Native::Resources;
    use NativeCall;

    our sub call_helper() is native(resource-lib('helper', :%?RESOURCES)) { * }
=end code
=begin head1
DESCRIPTION

Most of the time when you use NativeCall, you can just refer to libraries that
your OS has installed by default.  However, sometimes, you want to bundle native
libraries into your distribution.  There are several reasons for doing this, among
them are:

=for item1
You have no guarantee that a library will be installed, or that it will be of the
correct version, so you bundle your own

=for item1
You're wrapping C++ code, which is tricky (or sometimes impossible) to do with NativeCall,
so you need to write some C code to wrap the C++ into something NativeCall can use

This distribution provides two modules to help reduce the boilerplate you need to write
for this situation.  L<Native::Resources> provides C<resource-lib>, which consults
your distribution's resources and determines the correct file to use.  L<Native::Resources::Build>
provides a C<make> subroutine meant to be called from C<Build.pm> at your distribution's
root.
=end head1

=begin head1
EXAMPLES

L<https://github.com/hoelzro/p6-linenoise|Linenoise>
L<https://github.com/hoelzro/p6-xapian|Xapian>
=end head1

=begin head1
RATIONALE

L<http://hoelz.ro/blog/distributing-helper-libraries-with-perl6-modules>
=end head1

=begin head1
LICENSE

Copyright (c) 2016 Rob Hoelz <rob at hoelz.ro>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=end head1

module Native::Resources:auth<github:hoelzro>:ver<0.1.0> {
    # This needs to be in a class because of RT 127089
    my class Helper {
        method resource-lib(Str $libname, :%RESOURCES) returns Str {
            my @so-extensions = <.dll .dylib .so>;
            my @so-files = @so-extensions.map("lib/lib$libname" ~ *);

            my @non-empty-so-files = @so-files.grep: { %RESOURCES{$^filename} ~~ :!z };

            if @non-empty-so-files == 0 {
                die "Couldn't find a shared object for lib$libname";
            } elsif @non-empty-so-files > 1 {
                die "Found more than one shared object for lib$libname";
            }

            my $lib = @non-empty-so-files[0];
            %RESOURCES{$lib}.Str;
        }
    }

    #| Returns a filename that corresponds to the given library (denoted by
    #| C<$libname>).  You need to pass your C<%?RESOURCES> in so the sub
    #| knows where to look
    our sub resource-lib(Str $libname, :%RESOURCES) returns Code is export {
        -> --> Str {
            state $lib;

            unless $lib {
                $lib = Helper.resource-lib($libname, :%RESOURCES);
            }

            $lib
        }
    }
}
