:: Released under the GNU General Public License version 3 by J2897.

@echo OFF
pushd "%~dp0"
title Enable PowerShell Remoting Client

ver | find "Version 6." > nul
if %ERRORLEVEL% == 0 (
	REM Do OPENFILES to check for administrative privileges
	openfiles > nul
	if errorlevel 1 (
		color cf
		echo.Right-click on this file and select 'Run as administrator'.
		pause
		color
		exit /b 1
	)
)

set CP=%COMPUTERNAME%
set CA_CERT="%CD%\Certificates\ca.p7b"
set PSR_CLIENT_CERT="%CD%\Certificates\client.p12"
set DEFAULT_PSR_CLIENT_CERT_PASSWORD=password123

for /F "tokens=2 delims=:" %%i in ('"ipconfig | findstr IPv4"') do set LOCAL_IP=%%i
set LOCAL_IP=%LOCAL_IP: =%
set "RETURN=Press any key to return to the menu . . ."
set "TAB=	"

color 1b

:start
cls
echo ^<^<^<    Released under the GNU General Public License version 3 by J2897.     ^>^>^>
echo Computer name:%TAB%%CP%
echo Local IP:%TAB%%LOCAL_IP%
echo.
echo  1. Import CA Certificate.
echo  2. Import Client Certificate.
echo  3. Enable PSR Client.
echo  4. Run 'mmc.exe'.
echo  5. Exit.
echo.
choice /C:12345 /N /T 300 /D 5 /M "Which number:? "
if ERRORLEVEL 5 goto :end
if ERRORLEVEL 4 goto :mmc_exe
if ERRORLEVEL 3 goto :enable_PSR_client
if ERRORLEVEL 2 goto :import_client_cert
if ERRORLEVEL 1 goto :import_CA_cert
echo.
echo %RETURN%
pause > nul
goto :start

:import_CA_cert
cls
echo Importing CA Certificate . . .
echo.
if exist %CA_CERT% (certutil.exe -addstore -enterprise Root %CA_CERT%) else (echo File not found: %CA_CERT%)
echo.
echo %RETURN%
pause > nul
goto :start

:import_client_cert
cls
echo Importing PSR Client Certificate . . .
echo.
echo Please enter the password that you used to encrypt the Private Key with 
echo during the process of exporting the 'client.p12' file. Or to accept the default
set /P PSR_CLIENT_CERT_PASSWORD="password (%DEFAULT_PSR_CLIENT_CERT_PASSWORD%) just press 'Enter': "
if "%PSR_CLIENT_CERT_PASSWORD%" == "" (set PSR_CLIENT_CERT_PASSWORD=%DEFAULT_PSR_CLIENT_CERT_PASSWORD%)
if exist %PSR_CLIENT_CERT% (certutil.exe -importPFX -p %PSR_CLIENT_CERT_PASSWORD% %PSR_CLIENT_CERT%) else (echo File not found: %PSR_CLIENT_CERT%)
echo.
echo %RETURN%
pause > nul
goto :start

:enable_PSR_client
cls

REM Does the registry entry exist?
echo Checking if LocalAccountTokenFilterPolicy registry entry exists . . .
for /F "delims=" %%a in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System ^| find "LocalAccountTokenFilterPolicy"') do set REG_LATFP=%%a
if "%REG_LATFP%" == "" (
	echo LocalAccountTokenFilterPolicy doesn't exist.
	set REG_LATFP_EXISTS=0
) else (
	echo LocalAccountTokenFilterPolicy exists.
	set REG_LATFP_EXISTS=1
)

REM If the registry entry exists, is it ENABLED or DISABLED?
if "%REG_LATFP_EXISTS%" == "1" (
	call :reg_enabled_check	
)

REM If REG_LATFP_EXISTS=0 then TEMP_ENABLED_LATFP=1.
if "%REG_LATFP_EXISTS%" == "0" (call :temp_enable_LATFP)

REM If REG_LATFP_EXISTS=1 and REG_LATFP_ENABLED=0 then TEMP_ENABLED_LATFP=1.
if "%REG_LATFP_EXISTS%" == "1" (
	if "%REG_LATFP_ENABLED%" == "0" (
		call :temp_enable_LATFP
	)
)

REM If REG_LATFP_EXISTS=1 and REG_LATFP_ENABLED=1 then TEMP_ENABLED_LATFP=0.
if "%REG_LATFP_EXISTS%" == "1" (
	if "%REG_LATFP_ENABLED%" == "1" (
		set TEMP_ENABLED_LATFP=0
	)
)

REM  If WinRM is already running, set TEMP_ENABLED_WinRM to 0.
echo.
echo Temporarily starting the WinRM service . . .
echo.
set TEMP_ENABLED_WinRM=1& net start WinRM || (set TEMP_ENABLED_WinRM=0)

echo Adding TrustedHosts entry . . .
PowerShell -Command "& {Set-Item WSMan:\localhost\Client\TrustedHosts -Value *}"
title Enable PowerShell Remoting Client

REM If TEMP_ENABLED_WinRM=1, stop the WinRM service.
if "%TEMP_ENABLED_WinRM%" == "1" (
	echo.
	echo Stopping WinRM service . . .
	echo.
	net stop WinRM
)

if "%TEMP_ENABLED_LATFP%" == "1" (
	call :undo_temp_enable_LATFP
)

echo.
echo Assuming there's no problem with your certificates, your PC should now be able 
echo to talk to PowerShell Remoting servers. If there is a problem with your
echo certificates, then as soon as you've fixed them, you'll be good to go. You will
echo not have to run this a second time.
echo.
echo %RETURN%
pause > nul
goto :start

:mmc_exe
cls
echo Launching MMC (Microsoft Management Console) . . .
echo.
echo To get back to this window, close the MMC window.
"%SYSTEMROOT%\System32\mmc.exe"
echo.
echo %RETURN%
pause > nul
goto :start

:end
color
popd
exit /b 0

:reg_enabled_check
echo.
echo Checking status of LocalAccountTokenFilterPolicy . . .
for /F "delims=" %%a in ('echo %REG_LATFP% ^| find /C "0x1"') do set REG_LATFP_ENABLED=%%a
if "%REG_LATFP_ENABLED%" == "1" (echo It's enabled.) else (
	if "%REG_LATFP_ENABLED%" == "0" echo It's disabled.
)
exit /b 0

:temp_enable_LATFP
echo.
echo Temporarily setting LocalAccountTokenFilterPolicy to 1 . . .
echo.
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
set TEMP_ENABLED_LATFP=1
exit /b 0

:undo_temp_enable_LATFP
echo Setting LocalAccountTokenFilterPolicy back to 0 . . .
echo.
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 0 /f
exit /b 0
