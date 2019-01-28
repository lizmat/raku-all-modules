/*
*
*  ccwarning.c
*
*  Created by CC on 2018/10/12.
*  Copyright 2018 - now youhua deng (deng you hua | CC) <ccworld1000@gmail.com>
*  https://github.com/ccworld1000/CCLog
*
*  This program is free software; you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either version 2 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software
*  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
*  MA 02110-1301, USA.
*
*/
      

#include <CCLog.h>

int main(int argc, char const *argv[]) {
  if (argc == 1) {
    CCLog_warning (gCCLogWarningMsgParam);
    CCLog_warning (gCCLogWarningMsgMore);

    return -1;
  }

  CCLog_all_displayLog(1);
  CCLog_showLogTips(0);

  for (int i = 1; i < argc; i++) {
    char *arg = (char *)(*(argv + i));
    CCLog_warning(arg);
  }

  return 0;
}
