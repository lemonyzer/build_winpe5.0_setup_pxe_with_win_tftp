@echo off

rem
rem Build WinPE5.0_4_PXE
rem
rem 20131005 v1.0 Build WinPE5.0_4_PXE from the source files
rem

rem Current working directory where also the SP1 executable is located
rem Please don't touch!
set WORKDIR=%~dp0

rem Architecture of the Windows 8 DVD
rem Set "x86" for 32 bit architecture
rem Set "amd64" for 64 bit architecture
set ARCH=amd64

rem Temporary working directories
set TEMPDIR=C:\WinPE_%ARCH%

rem Path to the Windows Assessment and Deployment Kit
set KITPATH=C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit
if not exist "%KITPATH%" goto E_KITPATH

rem ###################################################################
rem # NORMALLY THERE IS NO NEED TO CHANGE ANYTHING BELOW THIS COMMENT #
rem ###################################################################

set WinPERoot=%KITPATH%\Windows Preinstallation Environment
set OSCDImgRoot=%KITPATH%\Deployment Tools\AMD64\Oscdimg

if exist C:\tftpboot rmdir /s /q C:\tftpboot
if errorlevel 1 goto E_DELTMP
if exist "%TEMPDIR%" rmdir /s /q "%TEMPDIR%"
if errorlevel 1 goto E_DELTMP
md C:\tftpboot
if errorlevel 1 goto E_MDOUT
md C:\tftpboot\Boot
if errorlevel 1 goto E_MDOUT

call "%KITPATH%\Windows Preinstallation Environment\copype.cmd" %ARCH% "%TEMPDIR%"
cd ..

"%KITPATH%\Deployment Tools\%ARCH%\DISM\dism.exe" /Mount-Wim /WimFile:"%TEMPDIR%\media\sources\boot.wim" /Index:1 /MountDir:"%TEMPDIR%\mount"
if errorlevel 1 goto E_MOUNT

copy "%TEMPDIR%\mount\Windows\Boot\PXE\*.*" "C:\tftpboot\Boot"
if errorlevel 1 goto E_COPY

"%KITPATH%\Deployment Tools\%ARCH%\DISM\dism.exe" /Unmount-Wim /MountDir:"%TEMPDIR%\mount" /Commit
if errorlevel 1 goto E_UNMOUNT

copy "%KITPATH%\Windows Preinstallation Environment\%ARCH%\Media\Boot\boot.sdi" "C:\tftpboot\Boot"
if errorlevel 1 goto E_COPY

copy "%TEMPDIR%\media\sources\boot.wim" "C:\tftpboot\Boot"
if errorlevel 1 goto E_COPY

bcdedit -createstore C:\BCD
if errorlevel 1 goto E_BCD
bcdedit -store C:\BCD -create {ramdiskoptions} /d "Ramdisk Options"
if errorlevel 1 goto E_BCD
bcdedit -store C:\BCD -set {ramdiskoptions} ramdisksdidevice boot
if errorlevel 1 goto E_BCD
bcdedit -store C:\BCD -set {ramdiskoptions} ramdisksdipath \Boot\boot.sdi
if errorlevel 1 goto E_BCD

for /f "tokens=1-3" %%a in ('bcdedit -store C:\BCD -create /d "WinPE 5.0 Boot Image" /application osloader') do set GUID1=%%c
if errorlevel 1 goto E_BCD
bcdedit -store C:\BCD -set %GUID1% systemroot \Windows
if errorlevel 1 goto E_BCD
bcdedit -store C:\BCD -set %GUID1% detecthal Yes
if errorlevel 1 goto E_BCD
bcdedit -store C:\BCD -set %GUID1% winpe Yes
if errorlevel 1 goto E_BCD
bcdedit -store C:\BCD -set %GUID1% osdevice ramdisk=[boot]\Boot\boot.wim,{ramdiskoptions}
if errorlevel 1 goto E_BCD
bcdedit -store C:\BCD -set %GUID1% device ramdisk=[boot]\Boot\boot.wim,{ramdiskoptions}
if errorlevel 1 goto E_BCD

bcdedit -store C:\BCD -create {bootmgr} /d "Windows 8.1 Boot Manager"
if errorlevel 1 goto E_BCD
bcdedit -store C:\BCD -set {bootmgr} timeout 30
if errorlevel 1 goto E_BCD
bcdedit -store C:\BCD -set {bootmgr} displayorder %GUID1%
if errorlevel 1 goto E_BCD

copy "C:\BCD" "C:\tftpboot\Boot"
if errorlevel 1 goto E_COPY

if exist "%TEMPDIR%" rmdir /s /q "%TEMPDIR%"
if errorlevel 1 goto E_DELTMP

if exist C:\BCD del C:\BCD
if errorlevel 1 goto E_DELBCD
if exist C:\BCD.LOG del /a C:\BCD.LOG
if errorlevel 1 goto E_DELBCD
if exist C:\BCD.LOG1 del /a C:\BCD.LOG1
if errorlevel 1 goto E_DELBCD
if exist C:\BCD.LOG2 del /a C:\BCD.LOG2
if errorlevel 1 goto E_DELBCD

goto DONE

:E_KITPATH
set MESSAGE=Could not find the Windows ADK folder!
goto END

:E_DELTMP
set MESSAGE=Could not delete temporary folder!
goto END

:E_MDOUT
set MESSAGE=Could not create output folder!
goto END

:E_MOUNT
set MESSAGE=Could not mount boot.wim!
goto END

:E_COPY
set MESSAGE=Could not copy this file(s) into the output folder!
goto END

:E_UNMOUNT
set MESSAGE=Could not unmount boot.wim!
goto END

:E_BCD
set MESSAGE=BCDEdit failed!
goto END

:E_DELBCD
set MESSAGE=Could not delete temporary BCD files!
goto END

:DONE
cls
set MESSAGE=Done
goto END

:END
echo.
echo %MESSAGE%
echo.
pause
exit