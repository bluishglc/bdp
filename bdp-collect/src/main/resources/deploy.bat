@echo off

set host=${app.host}
set user=${app.user.name}
set password=${app.user.password}
set baseDir=${app.user.home}
set home=${app.home}
set buildDir=${project.build.directory}
set binZip=${project.build.finalName}-bin.zip
set deltaBinZip=${project.build.finalName}-bin-delta.zip
set logHome=${app.log.home}

echo.
echo ***************************************************************************************
echo UPLOAD...
echo ***************************************************************************************

if "%~1"=="-delta" (
    goto uploadDeltaBinZip
) else (
    goto uploadBinZip
)

:uploadBinZip
@echo on
PSCP -l %user% -pw %password% "%buildDir%\\%binZip%" "%host%:/tmp/"
PLINK -l %user% -pw %password% %host% -t "if [ ! -d '%baseDir%' ];then mkdir %baseDir%;fi"
PLINK -l %user% -pw %password% %host% -t "if [ -d '%home%' ];then rm -rf %home%;fi"
PLINK -l %user% -pw %password% %host% -t "unzip /tmp/%binZip% -d %baseDir%/"
PLINK -l %user% -pw %password% %host% -t "mkdir  %logHome%/"
@echo off
goto startup

:uploadDeltaBinZip
@echo on
PSCP -l %user% -pw %password% "%buildDir%\\%deltaBinZip%" "%host%:/tmp/"
PLINK -l %user% -pw %password% %host% -t "unzip -o /tmp/%deltaBinZip% -d %baseDir%/"
@echo off
goto startup

:startup
echo.
echo ***************************************************************************************
echo STARTUP...
echo ***************************************************************************************

@echo on
:: if you want to start program automatically after deploy, uncomment next line.
:: PLINK -l %user% -pw %password% %host% -t "%baseDir%/${project.build.finalName}/bin/${project.artifactId}.sh restart-with-logging"
@echo off
