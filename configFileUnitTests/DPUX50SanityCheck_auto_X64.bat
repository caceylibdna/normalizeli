@echo off 

Set path=%cd%;%path%, %path%
Rem  this script must install Normalzie Service, Analyze Service, Phyon2.7 or above, 7-Zip. OS date and time formats as "dddd, MMMM dd, yyyy"
Set Script_Dir=C:\InstallScript
Set Zip_APP_Path=C:\Program Files\7-Zip
Set path=%cd%;%Zip_APP_Path%;%path%

Set File_DataTime=%date:~-4%%date:~4,2%%date:~7,2%

Set OTint=60
Set OTintL=300
Set OTintXL=600
Set OTintXXL=1200
Set OTintS=10

Set USERPWD=Administrator/Si*****0
Set DB_info=192.168.11.185
rem 192.168.10.40 localhost
Set DBUSERPWD=sa/Si*****0

Set Branch_dir=GA
rem qa LastBuild test ga
if %Branch_dir%==LastBuild (
	set Branch_Name=Develop
	) else (
	if %Branch_dir%==qa (
	    set Branch_Name=%Branch_dir%
	    ) else (
	    set Branch_Name="Others"
	    )
	)
if %Branch_dir%==ga (
	set Branch_Name=GA
	)

Set Mail_subject=[11.38@GZteam: %Branch_Name% branch][Fast Test]Normalize5.5GA with Updataset Sanity Check Status Notification
rem Set Mail_receiver=engineering-dev-gz@bdna.com,comochen@bdna.com,Graveeli@bdna.com,alin@bdna.com,dleung@bdna.com
Set Mail_receiver=engineering-dev-gz@bdna.com,comochen@bdna.com,Graveeli@bdna.com
Set Mail_LogFile="%cd%\logs\DPUX50_SQL_IIS_auto_X64_%File_DataTime%.log"

Set Mail_Attch_NormalizeFile=%cd%\logs\BDNA.log.%File_DataTime%.zip
Set Mail_Attch_AlayzeFile=%cd%\logs\UX.log.%File_DataTime%.zip
Set DP_Install_Path=C:\BDNA\Data Platform
Set UX_Install_Path=C:\BDNA\User Console
Set A50_LogFile="%UX_Install_Path%\log\*"
Set N50_LogFile="%DP_Install_Path%\log\*"

Set DP_Install_Type=ORACLE_IIS
Set UX_Install_Type=ORACLE
Set DownloadfilePath=\\192.168.8.25\installer\BDNA\Normalize5.3\%Branch_dir%
Set Download_DP_filePath=%DownloadfilePath%\Data_Platform*.exe
Set Download_UX_filePath=%DownloadfilePath%\User_Console*.exe
rem Set DownloadfilePath=\\192.168.8.84\NormalizeTrunk_Release\%Branch_dir%\*_x64.exe

Set Script_Dir=C:\InstallScript
Set DP_Installer_file_path=%Script_Dir%\Installer\DP
Set UX_Installer_file_path=%Script_Dir%\Installer\UX


Set Config_File_path=%Script_Dir%\Configfile
Set DP_Config_File_name=Installation.oracle.ldap.config
Set UX_Config_File_name=UX.oracle.ldap.config
rem Set Config_File_name=Norm.Configuration.config

rem Set /P Catalog_OffLine_URL= <Catalog_OffLine_URL.txt
rem Set Catalog_File="%Script_Dir%\Catalog\catalogsubscription.zip"

:main_wrok_Item
REM all of the installation files
Call :VM_Information
call :Get_DP_Installer_File
rem call :Get_US_DP_InstallFile
call :Start_Normalize_Installer_ConfigWizard
call :Get_UX_Installer_File
rem call :Get_US_UX_InstallFile
call :Start_UX_Installer_ConfigWizard
call :Start_Synchronize
rem call :Start_Synchronize2
rem call :Create_SalesDemo_TASK
rem call :Run_SalesDemo_TASK1
rem call :Run_SalesDemo_TASK2
call :Mail_Notification_Succeed
Goto :End

:VM_Information
Echo ################# Test Environment Information ########################
ipconfig>IP.txt
rem skip=7 is IPv4 only, skip=8 is containing the IPv6
for /f "skip=8 tokens=2 delims==:" %%i in (IP.txt) do (  
    Echo Host IP is :%%i
    Goto :NextVMInfo
    )
:NextVMInfo
Echo Host login is : %USERPWD%
Echo SQLServer IP is : %DB_info%
Echo SQLServer login is : %DBUSERPWD%
Goto :EOF

:Get_DP_Installer_File
Echo ################# get installer file name ########################
Echo .

Echo [%time%] Copy installer from Build server share folder ...
rem create the share folder.
net use %DownloadfilePath% /User:cluser cluser@bdna

rem for download Data Platform Installer
If not Exist "%DP_Installer_file_path%" ( mkdir "%DP_Installer_file_path%" )

If Exist "%DP_Installer_file_path%\*.*" ( Del /Q "%DP_Installer_file_path%\*.*" )

xcopy /Y /z "%Download_DP_filePath%" "%DP_Installer_file_path%\"
if %errorlevel% ==0 ( Echo [%time%] download Data Platform completed ... ) else (
	Echo [%time%] installation file download failed 
	net use %DownloadfilePath% /delete
	Goto :Mail_Notification_Failed	
	)

rem delete the share folder
net use %DownloadfilePath% /delete

rem get the installer filename
for /f %%i in ('dir "%DP_Installer_file_path%\*.*" /B /O:-d') do ( set DP_Installer_file_name=%%i)

if %DP_Installer_file_name% NEQ "" ( echo [%time%] Install_file_name: %DP_Installer_file_name% ) else (
	Echo [%time%] Can't found the Data Platform installation file...
	Goto :Mail_Notification_Failed	
	)

Goto :EOF

:Get_US_DP_InstallFile
Echo ################# get installer file name ########################
Echo .

Echo [%time%] Copy installer from Build server share folder ...
rem create the share folder.
net use \\nas2\shared /User:bdnacorp\FriendyHua huafp3
for /f "tokens=1" %%A in ('dir "\\nas2\shared\product\nightly-builds\normalize\5.0.0\dev" /AD /O-D /B') do (
 set recent=%%A
 echo %recent%)
 
rem for download Data Platform Installer
If not Exist "%DP_Installer_file_path%" ( mkdir "%DP_Installer_file_path%" )

If Exist "%DP_Installer_file_path%\*.*" ( Del /Q "%DP_Installer_file_path%\*.*" )

copy /Y /z "\\nas2\shared\product\nightly-builds\normalize\5.0.0\dev\%recent%\Data*.exe" "%DP_Installer_file_path%\"
if %errorlevel% ==0 ( Echo [%time%] download Data Platform completed ... ) else (
	Echo [%time%] installation file download failed 
	net use %DownloadfilePath% /delete
	Goto :Mail_Notification_Failed	
	)

rem delete the share folder
net use \\nas2\shared /delete

rem get the installer filename
for /f %%i in ('dir "%DP_Installer_file_path%\*.*" /B /O:-d') do ( set DP_Installer_file_name=%%i)

if %DP_Installer_file_name% NEQ "" ( echo [%time%] Install_file_name: %DP_Installer_file_name% ) else (
	Echo [%time%] Can't found the Data Platform installation file...
	Goto :Mail_Notification_Failed	
	)

Goto :EOF

:Start_Normalize_Installer_ConfigWizard
Echo.
Echo [%time%] Starting Running Normalize Installer Silent Setup ...
Echo.
Echo ############### Show your settings ###########################
Echo ## Data Platform Installer Name: %DP_Installer_file_name%
Echo. 
Echo ## Normalize Install Path: %DP_Install_Path%
Echo. 
Echo ## Normalize Install Type: %DP_Install_type%
Echo ###############################################################
Echo.
ping /n %OTintS% 127.1>nul
Echo "%DP_Installer_file_path%\%DP_Installer_file_name%" /S /SilentWizard=no /path="%DP_Install_Path%" /TYPE=%DP_Install_type% /overwrite=yes
Echo [%time%] DataPlatform Install start.
"%DP_Installer_file_path%\%DP_Installer_file_name%" /S /SilentWizard=No /path="%DP_Install_Path%" /TYPE=%DP_Install_type% /overwrite=yes
IF NOT %ERRORLEVEL%==0 Goto :Mail_Notification_Failed
Echo [%time%] DataPlatform Installed.
Echo.
Echo ################################
ping /n %OTintS% 127.1>nul
Echo "%DP_Install_Path%\Bin\ConfigurationWizardCMD.exe" -install /installconfig="%Config_File_path%\%DP_Config_File_name%"
Echo [%time%] DataPlatform configuration start.
"%DP_Install_Path%\Bin\ConfigurationWizardCMD.exe" -install /installconfig="%Config_File_path%\%DP_Config_File_name%"
IF NOT %ERRORLEVEL%==0 Goto :Mail_Notification_Failed
Echo [%time%] DataPlatform configuration finish.
Echo.
Echo ################################
ping /n %OTintS% 127.1>nul
Echo [%time%] Checking the Configuration Wizard running State...
SC query NormalizeService |Find "STATE" >NS_State.txt
set /p service_status=<NS_State.txt
if "%service_status%"=="" ( goto Mail_Notification_Failed )
for %%1 in (NS_State.txt) do  for /f "tokens=4" %%i in (%%1) do (
echo Normalize_Service_Status: %%i
	if "%%i"=="RUNNING" ( echo Normalize Service Ready, Config Wizard completed successfully 
	) else ( 
	echo [%time%] Normalize Service NOT Ready ...
	Del /Q NS_State.txt
	Goto :Mail_Notification_Failed	)
	)
Del /Q NS_State.txt
Goto :EOF

:Get_UX_Installer_File
Echo ################# get installer file name ########################
Echo .

Echo [%time%] Copy installer from Build server share folder ...
rem connect the share folder.
net use %DownloadfilePath% /User:cluser cluser@bdna

rem download User Console Installer
If not exist %UX_Installer_file_path% ( mkdir %UX_Installer_file_path% )
If Exist "%UX_Installer_file_path%\*.*" ( Del /Q "%UX_Installer_file_path%\*.*" )
xcopy /Y /z "%Download_UX_filePath%" "%UX_Installer_file_path%\"
if %errorlevel% ==0 ( Echo [%time%] download UX completed ... ) else (
	Echo [%time%] Installation file download failed 
	net use %DownloadfilePath% /delete
	Goto :Mail_Notification_Failed	
	)

rem delete the share folder
net use %DownloadfilePath% /delete

rem get the installer filename
for /f %%u in ('dir "%UX_Installer_file_path%\*.*" /B /O:-d') do ( set UX_Installer_file_name=%%u)

if %UX_Installer_file_name% NEQ "" ( echo [%time%] Install_file_name: %UX_Installer_file_name% ) else (
	Echo [%time%] Can't found the User Console installation file...
	Goto :Mail_Notification_Failed	
	)

Goto :EOF

:Get_US_UX_InstallFile
Echo ################# get installer file name ########################
Echo .

Echo [%time%] Copy installer from Build server share folder ...
rem create the share folder.
net use \\nas2\shared /User:bdnacorp\FriendyHua huafp3
for /f "tokens=1" %%A in ('dir "\\nas2\shared\product\nightly-builds\normalize\5.0.0\dev" /AD /O-D /B') do (
 set recent=%%A
 echo %recent%)

rem for download User Console Installer
If not exist %UX_Installer_file_path% ( mkdir %UX_Installer_file_path% )
If Exist "%UX_Installer_file_path%\*.*" ( Del /Q "%UX_Installer_file_path%\*.*" )

copy /Y "\\nas2\shared\product\nightly-builds\normalize\5.0.0\dev\%recent%\User*.exe" "%UX_Installer_file_path%\"

if %errorlevel% ==0 ( Echo [%time%] download UX completed ... ) else (
	Echo [%time%] Installation file download failed 
	net use %DownloadfilePath% /delete
	Goto :Mail_Notification_Failed	
	)

rem delete the share folder
net use %DownloadfilePath% /delete

rem get the installer filename
for /f %%u in ('dir "%UX_Installer_file_path%\*.*" /B /O:-d') do ( set UX_Installer_file_name=%%u)

if %UX_Installer_file_name% NEQ "" ( echo [%time%] Install_file_name: %UX_Installer_file_name% ) else (
	Echo [%time%] Can't found the User Console installation file...
	Goto :Mail_Notification_Failed	
	)

Goto :EOF

:Start_UX_Installer_ConfigWizard
Echo.
Echo [%time%] Starting Running User Console Installer Silent Setup ...
Echo.
Echo ############### Show your settings ###########################
Echo ## User Console Installer Name: %UX_Installer_file_name%
Echo. 
Echo ## User Console Install Path: %UX_Install_Path%
Echo. 
Echo ## User Console Install Type: %UX_Install_type%
Echo ###############################################################
Echo.
ping /n %OTintS% 127.1>nul
Echo "%UX_Installer_file_path%\%UX_Installer_file_name%" /S /SilentWizard=NO /path="%UX_Install_Path%" /TYPE=%UX_Install_type% /overwrite=yes 
Echo [%time%] UserConsole install start.
"%UX_Installer_file_path%\%UX_Installer_file_name%" /S /SilentWizard=NO /path="%UX_Install_Path%" /TYPE=%UX_Install_type% /overwrite=yes
IF NOT %ERRORLEVEL%==0 Goto :Mail_Notification_Failed
Echo [%time%] UserConsole install finish.
Echo.
Echo ################################
ping /n %OTintS% 127.1>nul
Echo "%UX_Install_Path%\Bin\ConfigurationWizardCMD.exe" -install /installconfig="%Config_File_path%\%UX_Config_File_name%"
Echo [%time%] UserConsole configuration start.
"%UX_Install_Path%\Bin\ConfigurationWizardCMD.exe" -install /installconfig="%Config_File_path%\%UX_Config_File_name%"
IF NOT %ERRORLEVEL%==0 Goto :Mail_Notification_Failed
Echo [%time%] UserConsole configuration finish.
Echo.
Echo ################################
ping /n %OTintS% 127.1>nul
Echo [%time%] Srart running Analyze Configuration Wizard running State ...
SC query userconsoleservice |Find "STATE" >AS_State.txt
set /p service_status=<AS_State.txt
if "%service_status%"=="" ( goto Mail_Notification_Failed )
for %%1 in (AS_State.txt) do  for /f "tokens=4" %%i in (%%1) do (
echo UX_Service_Status: %%i
if "%%i"=="RUNNING" ( echo [%time%] UX Service Ready, Config Wizard completed successfully 
	) else ( 
	echo [%time%] UX Service NOT Ready ...
	Del /Q NS_State.txt
	Goto :Mail_Notification_Failed	)
	)
)
Del /Q AS_State.txt
Goto :EOF

:Start_Synchronize
Echo .
Echo .#######################################################
Echo  ####### start running normalize Synchronize ###########
Echo .#######################################################
Echo .
Echo.###########################

Echo starting Running Normalize Synchronize ...
Echo "%DP_Install_Path%\bin\NormalizeCMD.exe" -RUNPROCESS /PROCESS_ID="1"
"%DP_Install_Path%\bin\NormalizeCMD.exe" -RUNPROCESS /PROCESS_ID="1"

If %ErrorLevel% == 0 (Echo [%time%] normalize Synchronize start running ...
                      Goto :Sync_running_status) 
else (
    	Echo [%time%] normalize Synchronize failed  
	    Goto :End)

Goto :EOF

:Sync_running_status
Echo. ------------------------------------------------------------------
Echo.    --- Check Synchronize Task Status ---
Echo. ------------------------------------------------------------------

echo [%time%] "%DP_Install_Path%\bin\NormalizeCMD.exe" -checkcatalogupdatestatus 
:Re_check_SyncStatus
"%DP_Install_Path%\bin\NormalizeCMD.exe" -checkcatalogupdatestatus >JOB_Status.txt
for %%2 in (JOB_Status.txt) do for /f "tokens=1" %%J in (%%2) do (
Set Task_Status=%%J
)
echo Normalize Task Status: %task_status%

if "%task_Status%" == "FINISH" Goto Check_SyncFinish 
if "%task_Status%" == "ERROR" Goto Check_SyncError 
if "%task_Status%" NEQ "FINISH" Goto Check_Syncrunning 

:Check_SyncReady
rem echo [%time%] Sync panding, wait for sychronize completed ... 
ping /n %OTintXXL% 127.1>nul
Goto Re_check_SyncStatus 

:Check_Syncrunning
rem echo [%time%] Sync also running, please wait a while ....
ping /n %OTint% 127.1>nul
Goto Re_check_SyncStatus 

:Check_SyncFinish
echo [%time%] Sync running completed succeed... 
Goto :EOF

:Check_SyncError
Type "%bms_home%log\BDNA.log" |Find "0 ERROR"
echo [%time%] Sync running Error, please take a look at the attach log file ...
Goto :Mail_Notification_Failed

:Sync_Check_Timeout
echo [%time%] Sychronize running TimeOut, please take a look at the attach log file ...
Type "%DP_Install_Path%\log\BDNA.log" |Find "0 ERROR"
Goto :Mail_Notification_Failed

If exist JOB_Status.txt (Del /Q JOB_Status.txt)
If exist zip_log.txt (Del /Q zip_log.txt)

Goto :EOF

rem update from 5.2.1 to 5.2.2 --start
:Start_Synchronize2
Echo .
Echo .#######################################################
Echo  ####### start running normalize Synchronize ###########
Echo .#######################################################
Echo .
Echo.###########################

Echo starting Running Normalize Synchronize ...
Echo "%DP_Install_Path%\bin\NormalizeCMD.exe" -RUNPROCESS /PROCESS_ID="1"
"%DP_Install_Path%\bin\NormalizeCMD.exe" -RUNPROCESS /PROCESS_ID="1"

If %ErrorLevel% == 0 (Echo [%time%] normalize Synchronize start running ...
                      Goto :Sync_running_status2) 
else (
    	Echo [%time%] normalize Synchronize failed  
	    Goto :End)

Goto :EOF

:Sync_running_status2
Echo. ------------------------------------------------------------------
Echo.    --- Check Synchronize Task Status ---
Echo. ------------------------------------------------------------------

echo [%time%] "%DP_Install_Path%\bin\NormalizeCMD.exe" -checkcatalogupdatestatus 
:Re_check_SyncStatus2
"%DP_Install_Path%\bin\NormalizeCMD.exe" -checkcatalogupdatestatus >JOB_Status.txt
for %%2 in (JOB_Status.txt) do for /f "tokens=1" %%J in (%%2) do (
Set Task_Status=%%J
)
echo Normalize Task Status: %task_status%

if "%task_Status%" == "FINISH" Goto Check_SyncFinish2 
if "%task_Status%" == "ERROR" Goto Check_SyncError2 
if "%task_Status%" NEQ "FINISH" Goto Re_check_SyncStatus2 

:Check_SyncFinish2
echo [%time%] Sync running completed succeed... 
Goto :EOF

:Check_SyncError2
Type "%bms_home%log\BDNA.log" |Find "0 ERROR"
echo [%time%] Sync running Error, please take a look at the attach log file ...
Goto :Mail_Notification_Failed
rem update from 5.2.1 to 5.2.2 --end

:Create_SalesDemo_TASK
Echo .
Echo .#######################################################
Echo  ####### start running SalesDemo Task #########
Echo .#######################################################
Echo .
Del /Q %Script_Dir%\ID.txt
Echo Add 5.1 SalesDemo and MD Tasks
Echo Create IT-Mashup-Task: IT:HPUD.zip
"%DP_Install_Path%\bin\NormalizeCMD.exe" -CREATEPROCESS /PROCESS_NAME=HPUD /PROCESS_TYPE=NORMALIZE /SOURCE_TYPE="IT Discovery Tool,31" /DATASOURCE_TYPE=ZIP /NETWORK_PATH="\\192.168.8.25\app\BDNA\Normalize\SalesDemo\HPUD.zip" /NETWORK_USERNAME=bdnacn\chenm /NETWORK_PASSWORD=Simple.0 >%Script_Dir%\ID.txt
rem 10000
for /f "tokens=3" %%i in (%Script_Dir%\ID.txt) do (  
    Echo Task ID is :%%i
    Set ID=%%i
    )
Echo %ID%
Echo Combine to IT-Mashup Task: DB:CM_XYZ
"%DP_Install_Path%\bin\NormalizeCMD.exe" -ADDDATASOURCE /COMBINE_TO=%ID% /PROCESS_TYPE=NORMALIZE /SOURCE_TYPE="IT Discovery Tool,3" /DATASOURCE_TYPE=MSSQLSERVER /SERVER_NAME=192.168.8.8 /DATABASE=CM_XYZ /USERNAME=sa /PASSWORD=bdna202 /CONFIG="sccm.extractor.config"
rem 10001

Echo Combine to IT-Mashup Task: Mashup USer: HR
"%DP_Install_Path%\bin\NormalizeCMD.exe" -ADDDATASOURCE /COMBINE_TO=%ID% /PROCESS_TYPE=DATA_MASHUP /SOURCE_TYPE="Data Mashup,34" /DATASOURCE_TYPE=FILE /NETWORK_PATH="\\192.168.8.25\app\BDNA\Normalize\SalesDemo\HR.csv" /FILE_OBJECT_TYPE=User /NETWORK_USERNAME=bdnacn\chenm /NETWORK_PASSWORD=Simple.0
rem 10002

Echo Create PO Task
"%DP_Install_Path%\bin\NormalizeCMD.exe" -CREATEPROCESS /PROCESS_TYPE=PURCHASE_ORDER /SOURCE_TYPE="Purchase Order,34" /DATASOURCE_TYPE=FILE /NETWORK_PATH="\\192.168.8.25\app\BDNA\Normalize\SalesDemo\CDW_DEMO.csv" /NETWORK_USERNAME=bdnacn\chenm /NETWORK_PASSWORD=Simple.0
rem 10003

Echo Create MD-IT-task
"%DP_Install_Path%\bin\NormalizeCMD.exe" -CREATEPROCESS /PROCESS_NAME="MD" /PROCESS_TYPE=NORMALIZE /SOURCE_TYPE="IT Discovery Tool,31" /DATASOURCE_TYPE=ZIP /NETWORK_PATH="\\192.168.8.25\app\BDNA\Normalize\SalesDemo\MD_Adventist_Health_System_SCCM_150722110427.zip" /NETWORK_USERNAME=bdnacn\chenm /NETWORK_PASSWORD=Simple.0
rem 10004

Echo Create MD-PO-task
"%DP_Install_Path%\bin\NormalizeCMD.exe" -CREATEPROCESS /PROCESS_TYPE=PURCHASE_ORDER /SOURCE_TYPE="Purchase Order,34" /DATASOURCE_TYPE=FILE /NETWORK_PATH="\\192.168.8.25\app\BDNA\Normalize\SalesDemo\PO_MD_SAMPLE_012015.csv" /NETWORK_USERNAME=bdnacn\chenm /NETWORK_PASSWORD=Simple.0
rem 10005

Echo Add XSF task -- HP XSF
Copy /Y C:\Source\Backup\* C:\Source\
"%DP_Install_Path%\bin\NormalizeCMD.exe" -CREATEPROCESS /PROCESS_NAME="HP XSF" /PROCESS_TYPE=NORMALIZE /SOURCE_TYPE="IT Discovery Tool,43" /DATASOURCE_TYPE=XSF /XSF_IN="C:\Source" /XSF_OUT="C:\Output" /BATCH_SIZE=2000 /RULES=UPDATE
rem 10006

Echo Add 2 taskes of ServiceNow [3 sources]
"%DP_Install_Path%\bin\NormalizeCMD.exe" -CREATEPROCESS /PROCESS_NAME=ServiceNoew_C_S /PROCESS_TYPE=NORMALIZE /SOURCE_TYPE="IT Discovery Tool,35" /DATASOURCE_TYPE=API /IS_ENABLED_API=0 /UNC_PATH="\\192.168.8.25\app\BDNA\Normalize\SalesDemo\servicenow\ci" /UNC_USERNAME=bdnacn\chenm /UNC_PASSWORD=Simple.0
rem 10007

"%DP_Install_Path%\bin\NormalizeCMD.exe" -CREATEPROCESS /PROCESS_NAME=ServiceNoew_C_S /PROCESS_TYPE=NORMALIZE /SOURCE_TYPE="IT Discovery Tool,35" /DATASOURCE_TYPE=API /IS_ENABLED_API=0 /UNC_PATH="\\192.168.8.25\app\BDNA\Normalize\SalesDemo\servicenow\hd" /UNC_USERNAME=bdnacn\chenm /UNC_PASSWORD=Simple.0
rem 10008

Goto :EOF

:Run_SalesDemo_TASK1

"%DP_Install_Path%\bin\NormalizeCMD.exe" -runprocess /process_id=%ID%

If %ErrorLevel% == 0 (Echo [%time%] normalize Task1 start running ...
                      Goto :Task1_running_status) 
else (
    	Echo [%time%] normalize Task1 failed  
	    Goto :Mail_Notification_Failed)

Goto :EOF

:TASK1_running_status
Echo. ------------------------------------------------------------------
Echo.    --- Check Task1 Task Status ---
Echo. ------------------------------------------------------------------

echo [%time%] "%DP_Install_Path%\bin\NormalizeCMD.exe" -CHECKPROCESSSTATUS /PROCESS_ID=%ID% 
:Re_check_TASK1Status
"%DP_Install_Path%\bin\NormalizeCMD.exe" -CHECKPROCESSSTATUS /PROCESS_ID=%ID% >JOB_Status.txt
for %%2 in (JOB_Status.txt) do for /f "tokens=1" %%J in (%%2) do (
Set Task_Status=%%J
)
echo Normalize Task1 Status: %task_status%

if "%task_Status%" == "READY" Goto Check_TASK1Ready 
if "%task_Status%" == "RUNNING" Goto Check_TASK1running 
if "%task_Status%" == "FINISH" Goto Check_TASK1Finish 
if "%task_Status%" == "ERROR" Goto Check_TASK1Error 

if "%task_Status%" == "TIMEOUT" ( Goto TASK1_Check_Timeout )
else (
echo [%time%] Task1 running on the other exception, please take a look at the attach log file ...
Goto Mail_Notification_Failed )


:Check_TASK1Ready
rem echo [%time%] Task1 panding, wait for sychronize completed ... 
ping /n %OTintL% 127.1>nul
Goto Re_check_TASK1Status 

:Check_TASK1running
rem echo [%time%] Task1 also running, please wait a while ....
ping /n %OTintL% 127.1>nul
Goto Re_check_TASK1Status 

:Check_TASK1Finish
echo [%time%] Task1 running completed succeed... 
Goto :EOF

:Check_TASK1Error
Type "%DP_Install_Path%\log\BDNA.log" |Find "0 ERROR"
echo [%time%] TASK1 running Error, please take a look at the attach log file ...
Goto :Mail_Notification_Failed

:TASK1_Check_Timeout
echo [%time%] TASK1 running TimeOut, please take a look at the attach log file ...
Type "%DP_Install_Path%\log\BDNA.log" |Find "0 ERROR"
Goto :Mail_Notification_Failed

If exist JOB_Status.txt (Del /Q JOB_Status.txt)
If exist zip_log.txt (Del /Q zip_log.txt)

Goto :EOF

:Run_SalesDemo_TASK2
Set /a ID=%ID%+3
Echo Run SalesDemo TASK2
"%DP_Install_Path%\bin\NormalizeCMD.exe" -runprocess /process_id=%ID%
ping /n %OTintS% 127.1>nul
If %ErrorLevel% == 0 (Echo [%time%] normalize Task2 start running ...
                      Goto :Task2_running_status) 
else (
    	Echo [%time%] normalize Task2 failed  
	    Goto :End)

Goto :EOF

:TASK2_running_status
Echo. ------------------------------------------------------------------
Echo.    --- Check Task2 Task Status ---
Echo. ------------------------------------------------------------------

echo [%time%] "%DP_Install_Path%\bin\NormalizeCMD.exe" -CHECKPROCESSSTATUS /PROCESS_ID=%ID%
ping /n %OTint% 127.1>nul

:Re_check_TASK2Status
"%DP_Install_Path%\bin\NormalizeCMD.exe" -CHECKPROCESSSTATUS /PROCESS_ID=%ID% >JOB_Status.txt
for %%2 in (JOB_Status.txt) do for /f "tokens=1" %%J in (%%2) do (
Set Task_Status=%%J
)
echo Normalize Task2 Status: %task_status%

if "%task_Status%" == "READY" Goto Check_TASK2Ready 
if "%task_Status%" == "RUNNING" Goto Check_TASK2running 
if "%task_Status%" == "FINISH" Goto Check_TASK2Finish 
if "%task_Status%" == "ERROR" Goto Check_TASK2Error 
if "%task_Status%" == "TIMEOUT" ( Goto TASK2_Check_Timeout )
else (
echo [%time%] Task2 running on the other exception, please take a look at the attach log file ...

Goto Mail_Notification_Failed )


:Check_TASK2Ready
rem echo [%time%] Task2 panding, wait for sychronize completed ... 
ping /n %OTintL% 127.1>nul
Goto Re_check_TASK2Status 

:Check_TASK2running
rem echo [%time%] Task2 also running, please wait a while ....
ping /n %OTintL% 127.1>nul
Goto Re_check_TASK2Status 

:Check_TASK2Finish
echo [%time%] Task2 running completed succeed...
Echo Run the other Tasks background and sendEmail to Members.
Set /a ID=%ID%+1
"%DP_Install_Path%\bin\NormalizeCMD.exe" -runprocess /process_id=%ID%
Set /a ID=%ID%+1
"%DP_Install_Path%\bin\NormalizeCMD.exe" -runprocess /process_id=%ID%
Set /a ID=%ID%+1
"%DP_Install_Path%\bin\NormalizeCMD.exe" -runprocess /process_id=%ID%
Set /a ID=%ID%+1
"%DP_Install_Path%\bin\NormalizeCMD.exe" -runprocess /process_id=%ID%
Set /a ID=%ID%+1
"%DP_Install_Path%\bin\NormalizeCMD.exe" -runprocess /process_id=%ID%
Goto :Mail_Notification_Succeed

:Check_TASK2Error
Type "%DP_Install_Path%\log\BDNA.log" |Find "0 ERROR"
echo [%time%] TASK2 running Error, please take a look at the attach log file ...
Goto :Mail_Notification_Failed

:TASK2_Check_Timeout
echo [%time%] Sychronize running TimeOut, please take a look at the attach log file ...
Type "%DP_Install_Path%\log\BDNA.log" |Find "0 ERROR"
Goto :Mail_Notification_Failed

If exist JOB_Status.txt (Del /Q JOB_Status.txt)
If exist zip_log.txt (Del /Q zip_log.txt)

Goto :EOF

:Mail_Notification_Succeed
echo sending successed Email to members.
Echo python %cd%\sendEmail.py -t %Mail_receiver% -s "%Mail_subject% --- Succeed" -f %Mail_LogFile%
python %cd%\sendEmail.py -t %Mail_receiver% -s "%Mail_subject% --- Succeed" -f %Mail_LogFile%

Goto :End

:Mail_Notification_Failed
echo Making log files to attachments.
if exist %Mail_Attch_NormalizeFile% (Del /Q %Mail_Attch_NormalizeFile% )
if exist %Mail_Attch_AlayzeFile% (Del /Q %Mail_Attch_AlayzeFile% )
copy /Y "%A50_LogFile%" "%A50_LogFile%.%File_DataTime%.log" >zip_log.txt
copy /Y "%N50_LogFile%" "%N50_LogFile%.%File_DataTime%.log" >zip_log.txt
7z.exe a -tzip "%Mail_Attch_NormalizeFile%" "%N50_LogFile%.%File_DataTime%" -mx9 >>zip_log.txt
7z.exe a -tzip "%Mail_Attch_AlayzeFile%" "%A50_LogFile%.%File_DataTime%" -mx9 >>zip_log.txt
echo sending failed Email to members.
ping /n %OTint% 127.1>nul
Echo python %cd%\sendEmail.py -t %Mail_receiver% -s "%Mail_subject% --- Failed" -f %Mail_LogFile% -a "%Mail_Attch_AlayzeFile%","%Mail_Attch_NormalizeFile%"
python %cd%\sendEmail.py -t %Mail_receiver% -s "%Mail_subject% --- Failed" -f %Mail_LogFile% -a "%Mail_Attch_AlayzeFile%","%Mail_Attch_NormalizeFile%"

Goto :End

:End
Echo *******************
Echo --- Done ---
Exit