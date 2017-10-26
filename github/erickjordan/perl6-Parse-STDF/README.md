# Parse::STDF - Module for parsing files in Standard Test Data Format
Standard Test Data Format (STDF) is a widely used standard file format for semiconductor test information. 
It is a commonly used format produced by automatic test equipment (ATE) platforms from companies such as 
LTX-Credence, Roos Instruments, Teradyne, Advantest, and others.

A STDF file is compacted into a binary format according to a well defined specification originally designed by 
Teradyne. The record layouts, field definitions, and sizes are all described within the specification. Over the 
years, parser tools have been developed to decode this binary format in several scripting languages, but as 
of yet nothing has been released for Perl6.

Parse::STDF is a first attempt. It is an object oriented module containing methods which invoke APIs of
an underlying C library called **libstdf** (see <http://freestdf.sourceforge.net/>).  **libstdf** performs 
the grunt work of reading and parsing binary data into STDF records represented as C-structs.  These 
structs are in turn referenced as Perl6 class objects.

## SYNOPSIS

    use Parse::STDF;

    try
    {
      my $s = Parse::STDF.new( stdf => $stdf );
      while $s.get_record
      {
        given ( $s.recname )
        {
          when "MIR"
          {
            my $mir = $s.mir; 
            printf("Started At: %s\n", $mir.START_T.ctime);
            printf("Station Number: %d\n", $mir.STAT_NUM);
            printf("Station Mode: %s\n", $mir.MODE_COD.chr);
            printf("Retst_Code: %s\n", $mir.RTST_COD.chr);
            printf("Lot: %s\n", $mir.LOT_ID.cnstr);
            printf("Part Type: %s\n", $mir.PART_TYP.cnstr);
            printf("Node Name: %s\n", $mir.NODE_NAM.cnstr);
            printf("Tester Type: %s\n", $mir.TSTR_TYP.cnstr);
            printf("Program: %s\n", $mir.JOB_NAM.cnstr); 
            printf("Version: %s\n", $mir.JOB_REV.cnstr);
            printf("Sublot: %s\n", $mir.SBLOT_ID.cnstr);
            printf("Operator: %s\n", $mir.OPER_NAM.cnstr);
            printf("Executive: %s\n", $mir.EXEC_TYP.cnstr);
            printf("Test Code: %s\n", $mir.TEST_COD.cnstr);
            printf("Test Temperature: %s\n", $mir.TST_TEMP.cnstr);
            printf("Package Type: %s\n", $mir.PKG_TYP.cnstr);
            printf("Facility ID: %s\n", $mir.FACIL_ID.cnstr);
            printf("Design Revision: %s\n", $mir.DSGN_REV.cnstr);
            printf("Flow ID: %s\n", $mir.FLOW_ID.cnstr);
            last;
          }
          default {}
        }
      }
      CATCH
      {
        when X::Parse::STDF { say $_.message; }
        default { say $_; }
      }
    }

## INSTALLATION
<ul>
<li>Since Parse::STDF uses libstdf.so, libstdf.so must be in your library path (i.e. /usr/local/lib).
To install libstdf.so on Ubuntu for example, use the following commands:
</li>
</ul>
<pre><code>
    $ wget https://sourceforge.net/projects/freestdf/files/libstdf/libstdf-0.4.tar.bz2
    $ bunzip2 libstdf-0.4.tar.bz2
    $ tar -xvf libstdf-0.4.tar
    $ cd libstdf-0.4
    $ ./configure --disable-warn-untested
    $ make
    $ sudo make install
    $ sudo ldconfig
</code></pre>
<ul>
<li>Using zef (Rakudo module management tool) install:
</li>
</ul>
<pre><code>
    $ zef install Parse::STDF
</code></pre>


## TESTED PLATFORMS
The following platforms have been tested:
*  RHEL Linux 6.x (x84\_64)
*  Ubuntu 16.04 LTS (x86\_64)  

[![Build Status](https://travis-ci.org/erickjordan/perl6-Parse-STDF.svg?branch=master)](https://travis-ci.org/erickjordan/perl6-Parse-STDF)

## EXAMPLES
Have a look at the examples. There are several scripts that demonstrate how to access the underlying objects and their attributes.
In particular, **dump_records_to_ascii.p6** does a fair job of visiting each Parse::STDF object class.

## NativeCall
Parse::STDF uses NativeCall to interface with **libstdf**.  Its easy to use, a natural fit and the next best 
thing since sliced cheese.  No need for ::XS, SWIG (or other bridging software) to interface a C library with Perl.
NativeCall makes installation of Parse::STDF simple and straightforward.  There are only two things required 
to get Parse::STDF up and running.  Thing one; install **libstdf**. Thing two; install Parse::STDF.

The appeal for using **libstdf** is in its representation of STDF records using C-structs.  These structs
are highly reusable and provide a solid foundation to quickly and easily build an application specific parser.
For example, a parser to extract token/value pairs from DTR records to insert rows into a data base table.

NativeCall represents C-structs nicely as Perl6 class objects.  This is accomplished by declaring a Perl6 class
using the **repr** trait.  See detail documenation here <https://doc.perl6.org/language/nativecall>.  In addition
to C-structs NativeCall also represents pointer types which is critical for navigating the various APIs and 
structs employed by **libstdf**.  These powerful features (and others) make it possible to extend Perl seamlessly
without having to write customized C code. 

### NativeCast
Navigating objects of **libstdf** requires a fair amount of C type casting.  Following example was taken from
**libstdf/examples/dump_records_to_ascii.c**:

    case REC_DTR: {
      rec_dtr *dtr = (rec_dtr*)rec;
      print_str("TEXT_DAT", dtr->TEXT_DAT);
      break;
    }

Here, `rec` is a pointer to C-struct called `rec_unknown`.  It is later type casted as a `rec_dtr` type.  To mimic 
this behavior in Perl6 NativeCall provides an API called `nativecast` which effectively performs the same task as a C
type cast.  The above can be written as the following in perl6:

    nativecast(Pointer[rec_dtr], Pointer[rec]);

`nativecast` along with some other perl6 tricks made available by NaticeCall makes it possible to navigate **libstdf**
objects just as if it were written in C.

## SEE ALSO
For an intro to the Standard Test Data Format (along with references to detailed documentation) 
see <http://en.wikipedia.org/wiki/Standard_Test_Data_Format>.
