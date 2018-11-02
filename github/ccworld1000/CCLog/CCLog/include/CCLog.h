
#ifndef ____CCLOG_H____
#define ____CCLOG_H____

#include <stdio.h>

#if defined(__cplusplus)
#define CC_EXPORT extern "C"
#else
#define CC_EXPORT extern
#endif

typedef enum {
    /*
      Normal log
    */
    CCLogTypeNormal,
    /*
      Warning log
    */
    CCLogTypeWarning,
    /*
      Error log
    */
    CCLogTypeError,
    /*
      Timer log
    */
    CCLogTypeTimer,
    /*
      Loop log
    */
    CCLogTypeLoop,
    /*
      Thread log
    */
    CCLogTypeThread,
    /*
      Print log
    */
    CCLogTypePrint,
    /*
      Say log
    */
    CCLogTypeSay,
    /*
      Die log
    */
    CCLogTypeDie,
    /*
      Network log
    */
    CCLogTypeNetwork,
} CCLogType;

typedef enum {
    /*
      Yellow color
    */
    CCLogColorTypeYellow = 33,
    /*
      White color
    */
    CCLogColorTypeWhite = 37,
    /*
      Green color
    */
    CCLogColorTypeGreen = 32,
    /*
      SkyBlue color
    */
    CCLogColorTypeSkyBlue = 36,
    /*
      Blue color
    */
    CCLogColorTypeBlue = 34,
    /*
      Purple color
    */
    CCLogColorTypePurple = 35,
    /*
      Red color
    */
    CCLogColorTypeRed = 31,
} CCLogColorType;

/*
 CCLog_showColor
*/
CC_EXPORT void CCLog_showColor (int isShowColor);

/*
 CCLog_showLogTips
*/
CC_EXPORT void CCLog_showColor (int isShowLogTips);

/*
  CCLog_normal
*/
CC_EXPORT void CCLog_normal (char * content);

/*
  CCLog_warning
*/
CC_EXPORT void CCLog_warning (char * content);

/*
  CCLog_error
*/
CC_EXPORT void CCLog_error (char * content);

/*
  CCLog_timer
*/
CC_EXPORT void CCLog_timer (char * content);

/*
  CCLog_loop
*/
CC_EXPORT void CCLog_loop (char * content);

/*
  CCLog_thread
*/
CC_EXPORT void CCLog_thread (char * content);

/*
  CCLog_print
*/
CC_EXPORT void CCLog_print (char * content);

/*
  CCLog_say
*/
CC_EXPORT void CCLog_say (char * content);

/*
  CCLog_die
*/
CC_EXPORT void CCLog_die (char * content);

/*
  CCLog_network
*/
CC_EXPORT void CCLog_network (char * content);

#endif
