use v6;
unit module UNIX::Daemonize::NativeSymbols;
use NativeCall;
sub fork() returns int32 is native is export {};
sub kill(int32, int32) returns int32 is native is export {};
sub setsid() returns int32 is native is export {};
sub getpgid(int32) returns int32 is native is export {};
sub umask(uint32) returns uint32 is native is export {};

enum SignalNumbers is export (
       HUP   =>  1,  
       INT   =>  2,  
       QUIT  =>  3,  
       ILL   =>  4,  
       ABRT  =>  6,  
       FPE   =>  8,  
       KILL  =>  9,  
       SEGV  => 11,  
       PIPE  => 13,  
       ALRM  => 14,  
       TERM  => 15,  
       USR1  => 16,
       USR2  => 17,
       CHLD  => 18,
       CONT  => 25,
       STOP  => 23,
       TSTP  => 24,
       TTIN  => 26,
       TTOU  => 27,
);
