unit module CCLog;

#!/usr/bin/env perl6
#
#  CCLog.pm6
#
#  Created by CC on 2018/10/12.
#  Copyright 2018 - now youhua deng (deng you hua | CC) <ccworld1000@gmail.com>
#  https://github.com/ccworld1000/CCLog
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#
#
    

use NativeCall;

#my Str $dlib = 'CCLog';
#my Str $dlib = ('CCLog', v1);
#my $dlib = ('CCLog', v1);
my $dlib = ('CCLog', v1);

BEGIN {
	#$dlib = ('CCLog', v1);
	#$dlib = ('CCLog');
	#$dlib = ('CCLog');
	$dlib = 'CCLog';
	#$dlib =  %?RESOURCES<libarchive.dll>

	$dlib =  %?RESOURCES<libCCLog.dylib>
}

our sub ccnormal (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_normal')
                  is export
                  {*}
                  
our sub ccwarning (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_warning')
                  is export
                  {*}
                  
our sub ccerror (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_error')
                  is export
                  {*}
                  
our sub cctimer (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_timer')
                  is export
                  {*}
                  
our sub ccloop (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_loop')
                  is export
                  {*}
                  
our sub ccthread (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_thread')
                  is export
                  {*}
                  
our sub ccsay (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_say')
                  is export
                  {*}
                  
our sub ccprint (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_print')
                  is export
                  {*}
                  
