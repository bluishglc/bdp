@echo off

set host=${app.host}
set user=${app.user.name}
set password=${app.user.password}
set baseDir=${app.user.home}
set home=${app.home}
set buildDir=${project.build.directory}
set binZip=${project.build.finalName}-bin.zip

echo.
echo ***************************************************************************************
echo UPLOAD...
echo ***************************************************************************************

@echo on
PSCP -l %user% -pw %password% "%buildDir%\\%binZip%" "%host%:/tmp/"
PLINK -l %user% -pw %password% %host% -t "if [ ! -d '%baseDir%' ];then mkdir %baseDir%;fi"
PLINK -l %user% -pw %password% %host% -t "if [ -d '%home%' ];then rm -rf %home%;fi"
PLINK -l %user% -pw %password% %host% -t "unzip /tmp/%binZip% -d %baseDir%/"
@echo off

echo.
echo ***************************************************************************************
echo STARTUP...
echo ***************************************************************************************

@echo on
:: if you want to start program automatically after deploy, uncomment next line.
:: PLINK -l %user% -pw %password% %host% "%baseDir%/${project.build.finalName}/bin/${project.artifactId}.sh restart"
@echo off
