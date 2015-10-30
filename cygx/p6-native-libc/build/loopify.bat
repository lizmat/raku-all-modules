@echo off
setlocal enableextensions

set CMD=%1
shift

:LOOP
if "%~1"=="" goto EXIT
set FILE=%1
set FILE=%FILE:/=\%
%CMD% %FILE% 2>NUL
shift
goto LOOP

:EXIT
endlocal
