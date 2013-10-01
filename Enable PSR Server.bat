:: Released under the GNU General Public License version 3 by J2897.

@echo OFF
pushd "%~dp0"
title Enable PowerShell Remoting Server

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
::set CN=test.com
set CA_CERT="%CD%\Certificates\ca.p7b"
set PSR_SERVER_CERT="%CD%\Certificates\server.p12"
set PSR_SERVER_CERT_PASSWORD=password123
set PSR_SERVER_PORT=5986

for /F "tokens=2 delims=:" %%i in ('"ipconfig | findstr IPv4"') do set LOCAL_IP=%%i
set LOCAL_IP=%LOCAL_IP: =%
set "RETURN=Press any key to return to the menu . . ."
set "AGAIN=Press any key to try again . . ."
set "TAB=	"

color 1b

:start
cls
echo ^<^<^<    Released under the GNU General Public License version 3 by J2897.     ^>^>^>
echo Computer name:%TAB%%CP%
echo Local IP:%TAB%%LOCAL_IP%
echo.
echo  1. Import CA Certificate.
echo  2. Import Server Certificate.
echo  3. Configure WinRM with HTTPS and default settings.
echo  4. Create the WinRM HTTPS Listener.
echo  5. View Listeners.
echo  6. Add "TrustedHosts".
echo  7. Add firewall entry.
echo  8. Exit.
echo.
choice /C:12345678 /T 120 /D 8 /M "Which number"
if ERRORLEVEL 8 goto :end
if ERRORLEVEL 7 goto :add_firewall_entry
if ERRORLEVEL 6 goto :add_TrustedHosts
if ERRORLEVEL 5 goto :view_listeners
if ERRORLEVEL 4 goto :create_listener
if ERRORLEVEL 3 goto :configure_WinRM
if ERRORLEVEL 2 goto :import_server_cert
if ERRORLEVEL 1 goto :import_CA_cert
echo.
echo %RETURN%
pause > nul
goto :start

:import_CA_cert
cls
echo Importing CA Certificate . . .
if exist %CA_CERT% (certutil.exe -addstore -enterprise Root %CA_CERT%) else (echo File not found: %CA_CERT%)
echo.
echo %RETURN%
pause > nul
goto :start

:import_server_cert
cls
echo Importing PSR Server Certificate . . .
if exist %PSR_SERVER_CERT% (certutil.exe -importPFX -p %PSR_SERVER_CERT_PASSWORD% %PSR_SERVER_CERT%) else (echo File not found: %PSR_SERVER_CERT%)
echo.
echo %RETURN%
pause > nul
goto :start

:configure_WinRM
cls
echo Configuring WinRM with HTTPS and default settings . . .
echo.
echo To get back to this window, type "exit" in the other window.
start /w /i winrm quickconfig -transport:https
echo.
echo %RETURN%
pause > nul
goto :start

:create_listener
cls
echo Creating WinRM HTTPS listener . . .
echo.
echo Please enter the 40 character Thumbprint. Don't worry about spaces, hyphens 
echo nor colons as they will be automatically stripped.
echo.
set /P THUMB="Right-click to paste: "

REM Remove spaces, hyphens and/or colons.
set THUMB=%THUMB: =%
set THUMB=%THUMB:-=%
set THUMB=%THUMB::=%

call :string_lengh THUMB STRLEN
if %STRLEN% NEQ 40 (
	echo.
	echo The Thumbprint you entered was %STRLEN% characters long:
	echo.
	echo %THUMB%
	echo.
	echo %AGAIN%
	pause > nul
	goto :create_listener
)
echo.
echo To get back to this window, type "exit" in the other window.
start /w /i winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="%CN%";CertificateThumbprint="%THUMB%";Port="%PSR_SERVER_PORT%"}
echo.
echo %RETURN%
pause > nul
goto :start

:view_listeners
cls
echo Showing listeners . . .
echo.
echo To get back to this window, type "exit" in the other window.
start /w /i winrm enumerate winrm/config/listener
echo.
echo %RETURN%
pause > nul
goto :start

:add_TrustedHosts
cls
echo Adding TrustedHosts . . .
echo.
echo To get back to this window, type "exit" in the other window.
start /w /i winrm set winrm/config/client @{TrustedHosts="*"}
echo.
echo %RETURN%
pause > nul
goto :start

:add_firewall_entry
cls
netsh advfirewall firewall add rule name="WinRM via HTTPS - Open Port %PSR_SERVER_PORT%" protocol=TCP dir=in localport=%PSR_SERVER_PORT% action=allow
echo.
echo %RETURN%
pause > nul
goto :start

:end
color
popd
exit /b 0

:string_lengh
setlocal enabledelayedexpansion
:loop
if not "!%1:~%LEN%!"=="" set /A LEN+=1 & goto :loop
(endlocal && set %2=%LEN%)
exit /b 0
