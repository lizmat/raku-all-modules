unit module CCLogFull:ver<0.0.5>:auth<youhua deng (deng you hua | CC) (ccworld1000@gmail.com, 2291108617@qq.com)>;

#!/usr/bin/env perl6
#
#  CCLogFull.pm6
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
    

use NativeCall;

my $dlib = 'libCCLog.so';

BEGIN {
  $dlib = %?RESOURCES<libCCLog.so>
}

our enum CCLogType is export
<
	CCLogTypeNormal
	CCLogTypeWarning
	CCLogTypeError
	CCLogTypeTimer
	CCLogTypeLoop
	CCLogTypeThread
	CCLogTypePrint
	CCLogTypeSay
	CCLogTypeDie
	CCLogTypeNetwork
>;
  
our enum CCLogColorType is export
(
	CCLogColorTypeWhite => 37,
	CCLogColorTypeBlue => 34,
	CCLogColorTypePurple => 35,
	CCLogColorTypeYellow => 33,
	CCLogColorTypeRed => 31,
	CCLogColorTypeSkyBlue => 36,
	CCLogColorTypeGreen => 32,
);
  

sub CCLog_showColor (int32 $isShowColor)
                  is native($dlib)
                  is symbol('CCLog_showColor')
                  is export
                  {*}

sub CCLog_showLogTips (int32 $isShowLogTips)
                  is native($dlib)
                  is symbol('CCLog_showLogTips')
                  is export
                  {*}

sub CCLog_all_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_all_displayLog')
                is export
                {*}
                
sub CCLog_normal_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_normal_displayLog')
                is export
                {*}
                
sub CCLog_warning_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_warning_displayLog')
                is export
                {*}
                
sub CCLog_error_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_error_displayLog')
                is export
                {*}
                
sub CCLog_timer_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_timer_displayLog')
                is export
                {*}
                
sub CCLog_loop_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_loop_displayLog')
                is export
                {*}
                
sub CCLog_thread_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_thread_displayLog')
                is export
                {*}
                
sub CCLog_print_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_print_displayLog')
                is export
                {*}
                
sub CCLog_say_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_say_displayLog')
                is export
                {*}
                
sub CCLog_die_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_die_displayLog')
                is export
                {*}
                
sub CCLog_network_displayLog (int32 $isDisplay)
                is native($dlib)
                is symbol('CCLog_network_displayLog')
                is export
                {*}
                
sub CCLog_normal (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_normal')
                  is export
                  {*}
                  
sub CCLog_warning (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_warning')
                  is export
                  {*}
                  
sub CCLog_error (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_error')
                  is export
                  {*}
                  
sub CCLog_timer (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_timer')
                  is export
                  {*}
                  
sub CCLog_loop (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_loop')
                  is export
                  {*}
                  
sub CCLog_thread (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_thread')
                  is export
                  {*}
                  
sub CCLog_print (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_print')
                  is export
                  {*}
                  
sub CCLog_say (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_say')
                  is export
                  {*}
                  
sub CCLog_die (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_die')
                  is export
                  {*}
                  
sub CCLog_network (Str $content)
                  returns int32
                  is native($dlib)
                  is symbol('CCLog_network')
                  is export
                  {*}
                  
