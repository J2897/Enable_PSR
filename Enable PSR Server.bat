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
set DEFAULT_PSR_SERVER_CERT_PASSWORD=password123
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
echo  6. Show SSL Certificate bindings.
echo  7. Add Firewall entry.
echo  8. Run 'mmc.exe'.
echo  9. Exit.
echo.
choice /C:123456789 /N /T 300 /D 9 /M "Which number?: "
if ERRORLEVEL 9 goto :end
if ERRORLEVEL 8 goto :mmc_exe
if ERRORLEVEL 7 goto :add_firewall_entry
if ERRORLEVEL 6 goto :show_SSL_bindings
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
echo.
if exist %CA_CERT% (certutil.exe -addstore -enterprise Root %CA_CERT%) else (echo File not found: %CA_CERT%)
echo.
echo %RETURN%
pause > nul
goto :start

:import_server_cert
cls
echo Importing PSR Server Certificate . . .
echo.
echo Please enter the password that you used to encrypt the Private Key with 
echo during the process of exporting the 'server.p12' file. Or to accept the default
set /P PSR_SERVER_CERT_PASSWORD="password (%DEFAULT_PSR_SERVER_CERT_PASSWORD%) just press 'Enter': "
if "%PSR_SERVER_CERT_PASSWORD%" == "" (set PSR_SERVER_CERT_PASSWORD=%DEFAULT_PSR_SERVER_CERT_PASSWORD%)
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

:choose_hostname
cls
echo ^<^<^<    Released under the GNU General Public License version 3 by J2897.     ^>^>^>
REM Count Personal certificates.
for /F "delims=" %%a in ('certutil -store my^| find /C "Subject: CN="') do set PERSONAL_CERTS=%%a
echo Number of Personal certificates: [ %PERSONAL_CERTS% ]
echo.
echo Set the Listener's Hostname:
echo.
echo  1. Computer's name (%CP%).
echo  2. Local IPv4 address (%LOCAL_IP%).
echo  3. Manually enter the Listener's Hostname.
if "%PERSONAL_CERTS%" == "1" (goto :get_CN) else (echo  4. Exit.)
:cont_choose_hostname
echo.
choice /C:12345 /T 120 /D 4 /M "Which number"
if ERRORLEVEL 5 goto :end
if ERRORLEVEL 4 if "%PERSONAL_CERTS%" == "1" (set HOST=%CN%) else (goto :end)
if ERRORLEVEL 3 (echo.) & (set /P HOST="Please enter the Listener's Hostname: ")
if ERRORLEVEL 2 set HOST=%LOCAL_IP%
if ERRORLEVEL 1 set HOST=%CP%
echo.
echo To get back to this window, type "exit" in the other window.
start /w /i winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="%HOST%";CertificateThumbprint="%THUMB%";Port="%PSR_SERVER_PORT%"}
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

:show_SSL_bindings
cls
echo Showing SSL Certificate bindings . . .
netsh http show sslcert
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

:string_lengh
setlocal enabledelayedexpansion
:loop
if not "!%1:~%LEN%!"=="" set /A LEN+=1 & goto :loop
(endlocal && set %2=%LEN%)
exit /b 0

:get_CN
REM Get Subject line.
for /F "delims=" %%a in ('certutil -store my^| find "Subject: CN="') do set SUBJECT=%%a
REM Divide using '=' as the separator and take the 2nd group of characters.
for /f "tokens=2 delims=^=" %%a in ("%SUBJECT%") do set CN=%%a
REM Divide using ',' as the separator and take the 1st group of characters.
for /f "tokens=1 delims=," %%a in ("%CN%") do set CN=%%a
echo  4. [Recommended] The Personal cert's Subject CN field ^(%CN%^).
echo  5. Exit.
goto :cont_choose_hostname
