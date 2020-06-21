@echo off

set host=${app.host}
set port=${app.ssh.port}
set user=${app.user.name}
set password=${app.user.password}
set baseDir=${app.user.home}
set home=${app.home}
set buildDir=${project.build.directory}
set binZip=${project.build.finalName}-bin.zip
set artifactId=${project.artifactId}

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
echo INITIALIZE...
echo ***************************************************************************************

@echo on
PLINK -l %user% -pw %password% %host% -t "%home%/bin/%artifactId%.sh init"
@echo off
