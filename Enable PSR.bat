:: Released under the GNU General Public License version 3 by J2897.

@echo OFF
pushd "%~dp0"
title Enable PowerShell Remoting

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

color 1b

:start
cls
echo ^<^<^<    Released under the GNU General Public License version 3 by J2897.     ^>^>^>
echo NOTE: In PowerShell Remoting, the computer which you control the other 
echo computers from is considered the 'Client', and the other computers are 
echo considered the 'Servers' - even if they're not actually servers: If you 
echo maintain your families' computers, then your families' computers are considered
echo the 'Servers'.
echo.
echo  1. Enable a Client.
echo  2. Enable a Server.
echo  3. Exit.
echo.
choice /C:123 /T 120 /D 3 /M "Which number"
if ERRORLEVEL 3 goto :end
if ERRORLEVEL 2 call "%CD%\Enable PSR Server.bat"
if ERRORLEVEL 1 call "%CD%\Enable PSR Client.bat"

:end
color
popd
exit /b 0
