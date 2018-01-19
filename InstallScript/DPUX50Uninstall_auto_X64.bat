@echo off 

Set path=%cd%;%path%, %path%
Rem  this script must install Normalzie Service, Analyze Service, Phyon2.7 or above, 7-Zip. OS date and time formats as "dddd, MMMM dd, yyyy"
Set Script_Dir=C:\InstallScript
Set Zip_APP_Path=C:\Program Files\7-Zip
Set path=%cd%;%Zip_APP_Path%;%path%

Set File_DataTime=%date:~-4%%date:~4,2%%date:~7,2%

Set OTint=60
Set OTintL=300
Set OTintS=10

Set Mail_subject=Normalize5.0 Sanity Check Status Notification
rem Set Mail_receiver=engineering-dev-gz@bdna.com, alin@bdna.com, dleung@bdna.com
Set Mail_receiver=engineering-dev-gz@bdna.com
Set Mail_LogFile="%cd%\logs\N50_Silent_Oracle_IISExpress_Auto_%File_DataTime%.log"
Set Mail_LogFile2="%cd%\logs\A50_Silent_Oracle_IISExpress_Auto_%File_DataTime%.log"

Set DP_Install_Type=MSSQL_IISExpress
Set UX_Install_Type=MSSQL
Set DownloadfilePath=\\192.168.8.25\installer\BDNA\Normalize5.0\lastbuild
Set Download_DP_filePath=%DownloadfilePath%\Data_Platform*.exe
Set Download_UX_filePath=%DownloadfilePath%\User_Console*.exe
rem Set DownloadfilePath=\\192.168.8.84\NormalizeTrunk_Release\LastBuild\*_x64.exe

Set Script_Dir=C:\InstallScript
Set DP_Installer_file_path=%Script_Dir%\Installer\DP
Set UX_Installer_file_path=%Script_Dir%\Installer\UX
Set DP_Install_Path=C:\BDNA\Data Platform
Set UX_Install_Path=C:\BDNA\User Console

Set Config_File_path=%Script_Dir%\Configfile
Set DP_Config_File_name=Installation.config
Set UX_Config_File_name=UX.config
rem Set Config_File_name=Norm.Configuration.config

rem Set /P Catalog_OffLine_URL= <Catalog_OffLine_URL.txt
rem Set Catalog_File="%Script_Dir%\Catalog\catalogsubscription.zip"

:main_wrok_Item
call :Check_Exists_Server
call :Check_Exists_UX
call :Delothers
goto :End

:Check_Exists_Server
Echo .
Echo ##################################################################
Echo ########## Normalize Installer Silent Installation ###############
Echo ##################################################################
Echo.

Echo [%time%] Check and uninstall the exist service ...
If not Exist "%BMS_HOME%" ( echo [%time%] Data Platform Service Not Exists.
Goto Check_Exists_UX )
If Exist "%BMS_HOME%" echo [%time%] Uninstalling Data Platform Service.
If Exist "%BMS_HOME%Bin\bms.BmsService.exe" ( "%BMS_HOME%uninstall.exe" /S _?=%BMS_HOME% )
If Exist "%BMS_HOME%" ( rmdir /S /Q "%BMS_HOME%" )
If not Exist "%BMS_HOME%Bin\bms.BmsService.exe"  Echo [%time%] Uninstall Data Platform succeed.
goto :EOF

:Check_Exists_UX
If not Exist "%NORMALIZE_BI_HOME%" (Goto :Delothers)
If Exist "%NORMALIZE_BI_HOME%" echo [%time%] Uninstalling User Console Service.
If not Exist "%NORMALIZE_BI_HOME%\uninstall.exe" ( COPY /Y "%Script_Dir%\uninstall.exe" "%NORMALIZE_BI_HOME%\uninstall.exe")
If Exist "%NORMALIZE_BI_HOME%\Bin\BDNA.NormalizeBI.Service.exe" ( "%NORMALIZE_BI_HOME%\uninstall.exe" /S _?=%NORMALIZE_BI_HOME% )
If Exist "%NORMALIZE_BI_HOME%" ( "%NORMALIZE_BI_HOME%\uninstall.exe" /S _?=%NORMALIZE_BI_HOME% )
If not Exist "%NORMALIZE_BI_HOME%\Bin\BDNA.NormalizeBI.Service.exe" Echo [%time%] Uninstall User Console succeed.
If Exist "%NORMALIZE_BI_HOME%" ( rmdir /S /Q "%NORMALIZE_BI_HOME%" )
goto :EOF

:Delothers
Echo delete service if exist.
sc delete NormalizeService
sc delete UserConsoleService
Echo delete addremove info if exist.
regedit /S %Script_Dir%\UXlefted_uninstall.reg

:End
Echo *******************
Echo --- Done ---
shutdown -r -t 0