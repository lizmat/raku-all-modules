
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
  CCLog_printf
*/
void CCLog_printf (char * content, CCLogType type) {
  if (!content) return;

  
  CCLogColorType colorType = gCCLogNormalColor;
  char *tips = NULL;
  switch (type) {
	case CCLogTypeNormal:
		colorType =  gCCLogNormalColor;
		tips = "normal";
		break;
	case CCLogTypeWarning:
		colorType =  gCCLogWarningColor;
		tips = "warning";
		break;
	case CCLogTypeError:
		colorType =  gCCLogErrorColor;
		tips = "error";
		break;
	case CCLogTypeTimer:
		colorType =  gCCLogTimerColor;
		tips = "timer";
		break;
	case CCLogTypeLoop:
		colorType =  gCCLogLoopColor;
		tips = "loop";
		break;
	case CCLogTypeThread:
		colorType =  gCCLogThreadColor;
		tips = "thread";
		break;
	case CCLogTypePrint:
		colorType =  gCCLogPrintColor;
		tips = "print";
		break;
	case CCLogTypeSay:
		colorType =  gCCLogSayColor;
		tips = "say";
		break;
	case CCLogTypeDie:
		colorType =  gCCLogDieColor;
		tips = "die";
		break;
	case CCLogTypeNetwork:
		colorType =  gCCLogNetworkColor;
		tips = "network";
		break;
	default:
		colorType =  gCCLogNormalColor;
		tips = "normal";
		break;
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
