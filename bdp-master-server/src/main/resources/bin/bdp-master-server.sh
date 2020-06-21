#!/usr/bin/env bash

export BDP_MASTER_SERVER_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"

BDP_MASTER_LIB_DIR=${BDP_MASTER_SERVER_HOME}/lib
BDP_MASTER_CONF_DIR=${BDP_MASTER_SERVER_HOME}/conf
BDP_MASTER_PID=/tmp/${project.artifactId}.pid
BDP_MASTER_MAIN_CLASS="${app.mainClass}"

# ------------------------------------------------   Common Methods   ------------------------------------------------ #

showUsage()
{

    printHeading "PROJECT [ BDP-MASTER-SERVER ] USAGE"

    echo "# 说明：启动应用"
    echo "$0 start"
    echo

    echo "# 说明：停止应用"
    echo "$0 stop"
    echo

    echo "# 说明：重启应用"
    echo "$0 restart"
    echo

    echo "# 说明：持续读取日志文件并输出到控制台"
    echo "$0 tail-log"
    echo

    echo "# 说明：重启应用并持续读取日志文并输出到控制台"
    echo "$0 restart-with-logging"
    echo

    echo "# 说明：读取指定日期版本的主数据文件，更新到数据库中"
    echo "$0 update-master-data DATE"
    echo

    echo "# 示例：读取2018-09-01的主数据文件，更新到数据库中"
    echo "$0 update-master-data '2018-09-01'"
    echo
}

getJavaCmd() {
  if [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo "$JAVA_HOME/bin/java"
  else
    echo "java"
  fi
}

printHeading()
{
    title="$1"
    paddingWidth=$((($(tput cols)-${#title})/2-3))
    printf "\n%${paddingWidth}s"|tr ' ' '='
    printf "  $title  "
    printf "%${paddingWidth}s\n\n"|tr ' ' '='
}

# ------------------------------------------------    Major Methods   ------------------------------------------------ #

start() {
    java=$(getJavaCmd)
    nohup $java -Duser.timezone=Asia/Shanghai -classpath "$BDP_MASTER_CONF_DIR/:$BDP_MASTER_LIB_DIR/*" $BDP_MASTER_MAIN_CLASS >/dev/null 2>&1 &
    echo $! > $BDP_MASTER_PID
}

stop() {
    if [ -f $BDP_MASTER_PID ]; then
        # kill -0 == see if the PID exists
        if kill -0 `cat $BDP_MASTER_PID` > /dev/null 2>&1; then
            kill -9 `cat $BDP_MASTER_PID` > /dev/null 2>&1
        fi
    fi
}

restart() {
    stop
    start
}

tailLog() {
    clear
    tail -F ${app.log.home}/${project.artifactId}.log
}

updateMasterData() {
    validateTime "$1"
    mysql -h${bdp.master.db.host} -u${bdp.master.jdbc.user} -p${bdp.master.jdbc.password} -s --prompt=nowarning < $BDP_MASTER_CONF_DIR/bdp-master-data-$(date -d "$1" +"%F").sql
}

validateTime()
{
    if [ "$1" = "" ]
    then
        echo "Time is missing!"
        exit 1
    fi
    TIME=$1
    date -d "$TIME" >/dev/null 2>&1
    if [ "$?" != "0" ]
    then
        echo "Invalid Time: $TIME"
        exit 1
    fi
}

# -----------------------------------------------   Shell Scripts Entry   -------------------------------------------- #

case $1 in
    (start)
        start
    ;;
    (stop)
        stop
    ;;
    (restart)
        restart
    ;;
    (tail-log)
        tailLog
    ;;
    (restart-with-logging)
        restart
        tailLog
    ;;
    (update-master-data)
        shift
        updateMasterData "$@"
    ;;
    (*)
        showUsage
    ;;
esac
