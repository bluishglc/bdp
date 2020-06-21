@echo off
rem A batch script to build -> deploy -> restart
rem -- Laurence Geng
if [%1]==[] (
    echo.
    echo Usage: %0 [-delta] maven-profile-1 maven-profile-2 ...
    echo.
    echo Option: -delta: only deploy modified part, i.e. project artifact, used for development deploy.
    goto end
)

set deltaDeploy=0
if "%~1"=="-delta" (
    set deltaDeploy=1
    shift
)

set profiles=%~1

:loopProfiles
shift
if "%~1"=="" (
    goto build
) else (
    set profiles=%profiles%,%~1
    goto loopProfiles
)

:build
echo.
echo ***************************************************************************************
echo BUILD...
echo ***************************************************************************************
echo.

if "%profiles%"=="" (
    call mvn clean install -DskipTests=true
) else (
    call mvn clean install -DskipTests=true -P%profiles%
)

if "%errorlevel%"=="1" goto :buildfailed

rem for 'prd' env, skip deploy! 'prd' is always deployed manually!
if "%profiles%"=="prd" goto "buildsuccess"

if "%deltaDeploy%"=="1" (
    call target\deploy.bat -delta
) else (
    call target\deploy.bat
)

goto buildsuccess

:buildsuccess
echo.
echo.
echo ***************************************************************************************
echo BUILD SUCCESS!!
echo ***************************************************************************************
goto end

:buildfailed
echo.
echo.
echo ***************************************************************************************
echo BUILD FAILED!!
echo ***************************************************************************************
goto end

:end
