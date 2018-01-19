@echo off

set path=%cd%;%path%

Echo [%time%] start running ....

%cd%\DPUX51installationSanityCheck.bat >logs\DPUX50_SQL_IIS_auto_X64_%date:~-4%%date:~4,2%%date:~7,2%.log


Echo [%time%]   --- end ---

