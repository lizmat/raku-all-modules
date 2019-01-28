#!/usr/bin/env sh
#
#  install.sh
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
    

make

if [ -d CCLog/resources ] && [ -d resources ]; then
  if [ -f "CCLog/resources/libCCLog.so" ];then
    echo "Copying resources";
    cp CCLog/resources/*.so resources;
    cp CCLog/resources/*.dylib resources;
    if [ -f "CCLog/bin/ccsay" ];then
      echo "copy shell bin to /usr/local/bin!"
      cp CCLog/bin/cc* /usr/local/bin
    fi
  else
    echo "No resource library files found";
    echo "Please download the latest version from https://github.com/ccworld1000/CCLog"
  fi
else
  echo "The file is also destroyed."
  echo "Please download the latest version from https://github.com/ccworld1000/CCLog"
fi

