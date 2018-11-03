
#ifndef ____CCLOG_C____
#define ____CCLOG_C____

#include <CCLog.h>


/*
  show color control
*/
int gCCLogShowColor = 1;

/*
  show log tips control
*/
int gCCLogShowLogTips = 1;

/*
  CCLog_showColor
*/
void CCLog_showColor (int isShowColor) {
    if (isShowColor) {
        gCCLogShowColor = 1;
    } else {
        gCCLogShowColor = 0;
    }
}

/*
  CCLog_showLogTips
*/
void CCLog_showLogTips (int isShowLogTips) {
    if (isShowLogTips) {
        gCCLogShowLogTips = 1;
    } else {
        gCCLogShowLogTips = 0;
    }
}

/*
  gCCLogNormalColor value
*/
CCLogColorType gCCLogNormalColor = CCLogColorTypeWhite;

/*
  gCCLogWarningColor value
*/
CCLogColorType gCCLogWarningColor = CCLogColorTypeYellow;

/*
  gCCLogErrorColor value
*/
CCLogColorType gCCLogErrorColor = CCLogColorTypeBlue;

/*
  gCCLogTimerColor value
*/
CCLogColorType gCCLogTimerColor = CCLogColorTypeSkyBlue;

/*
  gCCLogLoopColor value
*/
CCLogColorType gCCLogLoopColor = CCLogColorTypePurple;

/*
  gCCLogThreadColor value
*/
CCLogColorType gCCLogThreadColor = CCLogColorTypeSkyBlue;

/*
  gCCLogPrintColor value
*/
CCLogColorType gCCLogPrintColor = CCLogColorTypeGreen;

/*
  gCCLogSayColor value
*/
CCLogColorType gCCLogSayColor = CCLogColorTypeGreen;

/*
  gCCLogDieColor value
*/
CCLogColorType gCCLogDieColor = CCLogColorTypeRed;

/*
  gCCLogNetworkColor value
*/
CCLogColorType gCCLogNetworkColor = CCLogColorTypeGreen;

/*
  gCCLogAllDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogAllDisplayLog = 1;

/*
  gCCLogNormalDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogNormalDisplayLog = 1;

/*
  gCCLogWarningDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogWarningDisplayLog = 1;

/*
  gCCLogErrorDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogErrorDisplayLog = 1;

/*
  gCCLogTimerDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogTimerDisplayLog = 1;

/*
  gCCLogLoopDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogLoopDisplayLog = 1;

/*
  gCCLogThreadDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogThreadDisplayLog = 1;

/*
  gCCLogPrintDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogPrintDisplayLog = 1;

/*
  gCCLogSayDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogSayDisplayLog = 1;

/*
  gCCLogDieDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogDieDisplayLog = 1;

/*
  gCCLogNetworkDisplayLog value [1 = show log, 0 = no log]
*/
int gCCLogNetworkDisplayLog = 1;

/*
  CCLog_printf
*/
void CCLog_printf (char * content, CCLogType type) {
  if (!content) return;

  
  CCLogColorType colorType = gCCLogNormalColor;
  char *tips = NULL;
  int displayLog = 0;
  switch (type) {
	case CCLogTypeNormal:
		colorType =  gCCLogNormalColor;
		tips = "normal";
		displayLog = gCCLogNormalDisplayLog;
		break;
	case CCLogTypeWarning:
		colorType =  gCCLogWarningColor;
		tips = "warning";
		displayLog = gCCLogWarningDisplayLog;
		break;
	case CCLogTypeError:
		colorType =  gCCLogErrorColor;
		tips = "error";
		displayLog = gCCLogErrorDisplayLog;
		break;
	case CCLogTypeTimer:
		colorType =  gCCLogTimerColor;
		tips = "timer";
		displayLog = gCCLogTimerDisplayLog;
		break;
	case CCLogTypeLoop:
		colorType =  gCCLogLoopColor;
		tips = "loop";
		displayLog = gCCLogLoopDisplayLog;
		break;
	case CCLogTypeThread:
		colorType =  gCCLogThreadColor;
		tips = "thread";
		displayLog = gCCLogThreadDisplayLog;
		break;
	case CCLogTypePrint:
		colorType =  gCCLogPrintColor;
		tips = "print";
		displayLog = gCCLogPrintDisplayLog;
		break;
	case CCLogTypeSay:
		colorType =  gCCLogSayColor;
		tips = "say";
		displayLog = gCCLogSayDisplayLog;
		break;
	case CCLogTypeDie:
		colorType =  gCCLogDieColor;
		tips = "die";
		displayLog = gCCLogDieDisplayLog;
		break;
	case CCLogTypeNetwork:
		colorType =  gCCLogNetworkColor;
		tips = "network";
		displayLog = gCCLogNetworkDisplayLog;
		break;
	default:
		colorType =  gCCLogNormalColor;
		tips = "normal";
		displayLog = gCCLogNormalDisplayLog;
		break;
  }

  if (!gCCLogAllDisplayLog) {
    return;
  }

  if (!displayLog) {
    return;
  }

  if (gCCLogShowColor) {
      if (gCCLogShowLogTips) {
        printf("\033[%dm[ CCLog %s ] %s\033[0m\n", colorType, tips, content);
      } else {
        printf("\033[%dm%s\033[0m\n", colorType, content);
      }
  } else {
      if (gCCLogShowLogTips) {
        printf("[ CCLog %s ] %s\n", tips, content);
      } else {
        printf("%s\n", content);
      }
  }
}


/*
  CCLog_all_displayLog
*/
void CCLog_all_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogAllDisplayLog = 1;
  } else {
      gCCLogAllDisplayLog = 0;
  }
}

/*
  CCLog_normal_displayLog
*/
void CCLog_normal_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogNormalDisplayLog = 1;
  } else {
      gCCLogNormalDisplayLog = 0;
  }
}

/*
  CCLog_warning_displayLog
*/
void CCLog_warning_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogWarningDisplayLog = 1;
  } else {
      gCCLogWarningDisplayLog = 0;
  }
}

/*
  CCLog_error_displayLog
*/
void CCLog_error_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogErrorDisplayLog = 1;
  } else {
      gCCLogErrorDisplayLog = 0;
  }
}

/*
  CCLog_timer_displayLog
*/
void CCLog_timer_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogTimerDisplayLog = 1;
  } else {
      gCCLogTimerDisplayLog = 0;
  }
}

/*
  CCLog_loop_displayLog
*/
void CCLog_loop_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogLoopDisplayLog = 1;
  } else {
      gCCLogLoopDisplayLog = 0;
  }
}

/*
  CCLog_thread_displayLog
*/
void CCLog_thread_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogThreadDisplayLog = 1;
  } else {
      gCCLogThreadDisplayLog = 0;
  }
}

/*
  CCLog_print_displayLog
*/
void CCLog_print_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogPrintDisplayLog = 1;
  } else {
      gCCLogPrintDisplayLog = 0;
  }
}

/*
  CCLog_say_displayLog
*/
void CCLog_say_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogSayDisplayLog = 1;
  } else {
      gCCLogSayDisplayLog = 0;
  }
}

/*
  CCLog_die_displayLog
*/
void CCLog_die_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogDieDisplayLog = 1;
  } else {
      gCCLogDieDisplayLog = 0;
  }
}

/*
  CCLog_network_displayLog
*/
void CCLog_network_displayLog  (int isDisplay) {
  if (isDisplay) {
      gCCLogNetworkDisplayLog = 1;
  } else {
      gCCLogNetworkDisplayLog = 0;
  }
}

/*
  CCLog_normal
*/
void CCLog_normal (char * content) {
  if (!content) return;

  CCLog_printf (content, CCLogTypeNormal);
}

/*
  CCLog_warning
*/
void CCLog_warning (char * content) {
  if (!content) return;

  CCLog_printf (content, CCLogTypeWarning);
}

/*
  CCLog_error
*/
void CCLog_error (char * content) {
  if (!content) return;

  CCLog_printf (content, CCLogTypeError);
}

/*
  CCLog_timer
*/
void CCLog_timer (char * content) {
  if (!content) return;

  CCLog_printf (content, CCLogTypeTimer);
}

/*
  CCLog_loop
*/
void CCLog_loop (char * content) {
  if (!content) return;

  CCLog_printf (content, CCLogTypeLoop);
}

/*
  CCLog_thread
*/
void CCLog_thread (char * content) {
  if (!content) return;

  CCLog_printf (content, CCLogTypeThread);
}

/*
  CCLog_print
*/
void CCLog_print (char * content) {
  if (!content) return;

  CCLog_printf (content, CCLogTypePrint);
}

/*
  CCLog_say
*/
void CCLog_say (char * content) {
  if (!content) return;

  CCLog_printf (content, CCLogTypeSay);
}

/*
  CCLog_die
*/
void CCLog_die (char * content) {
  if (!content) return;

  CCLog_printf (content, CCLogTypeDie);
}

/*
  CCLog_network
*/
void CCLog_network (char * content) {
  if (!content) return;

  CCLog_printf (content, CCLogTypeNetwork);
}

#endif
