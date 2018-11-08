
#ifndef ____CCLOG_H____
#define ____CCLOG_H____

typedef enum {
    /*
      Normal
    */
    CCLogTypeNormal,
    /*
      Warning
    */
    CCLogTypeWarning,
    /*
      Error
    */
    CCLogTypeError,
    /*
      Timer
    */
    CCLogTypeTimer,
    /*
      Loop
    */
    CCLogTypeLoop,
    /*
      Thread
    */
    CCLogTypeThread,
    /*
      Say
    */
    CCLogTypeSay,
    /*
      Print
    */
    CCLogTypePrint,
} CCLogType;

/*
  CCLog_normal
*/
void CCLog_normal (char * content);

/*
  CCLog_warning
*/
void CCLog_warning (char * content);

/*
  CCLog_error
*/
void CCLog_error (char * content);

/*
  CCLog_timer
*/
void CCLog_timer (char * content);

/*
  CCLog_loop
*/
void CCLog_loop (char * content);

/*
  CCLog_thread
*/
void CCLog_thread (char * content);

/*
  CCLog_say
*/
void CCLog_say (char * content);

/*
  CCLog_print
*/
void CCLog_print (char * content);

#endif
