#!/usr/bin/env bash

export BDP_STREAM_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"

BDP_STREAM_CLUSTER_NODES=${app.cluster.nodes}
BDP_STREAM_LIB_DIR=$BDP_STREAM_HOME/lib
BDP_STREAM_CONF_DIR=$BDP_STREAM_HOME/conf
BDP_STREAM_PID=/tmp/${project.artifactId}.pid
BDP_STREAM_JAR=${project.build.finalName}.jar
BDP_STREAM_MAIN_CLASS=${app.mainClass}
BDP_STREAM_DEPENDENCY_JARS=""

for JAR in $(ls ${BDP_STREAM_LIB_DIR})
do
    if [ ! "$JAR" = "$BDP_STREAM_JAR" ]
    then
        BDP_STREAM_DEPENDENCY_JARS="$BDP_STREAM_LIB_DIR/$JAR,$BDP_STREAM_DEPENDENCY_JARS"
    fi
done
BDP_STREAM_DEPENDENCY_JARS=${BDP_STREAM_DEPENDENCY_JARS%,}

# ------------------------------------------------   Common Methods   ------------------------------------------------ #

showUsage() {
    printHeading "BDP-STREAM USAGE"
    echo "# 创建数据库"
    echo "$0 create-schema"
    echo
    echo "# 启动程序"
    echo "$0 start"
    echo
    echo "# 终止程序"
    echo "$0 stop"
    echo
    echo "# 重新启动程序（先终止先启动）"
    echo "$0 restart"
    echo
    echo "# 监控日志输出"
    echo "$0 tail-log"
    echo
    echo "# 重新启动程序并持续监控Driver端日志输出"
    echo "$0 restart-with-logging"
    echo
    echo "# 查看程序运行状态"
    echo "$0 status"
    echo
    echo "# 查看程序进程"
    echo "$0 show-ps"
    echo
}

printHeading() {
    title="$1"
    paddingWidth=$((($(tput cols)-${#title})/2-3))
    printf "\n%${paddingWidth}s"|tr ' ' '='
    printf " [ $title ] "
    printf "%${paddingWidth}s\n\n"|tr ' ' '='
}

# ------------------------------------------------    Major Methods   ------------------------------------------------ #

printMetricTableSchema()
{
    table="metric"
    echo "disable '$table'"
    echo "drop '$table'"
    echo "create '$table', {NAME=>'f', VERSIONS=>1, TTL => 'FOREVER', COMPRESSION => 'SNAPPY', BLOCKCACHE => 'true'}"
}

printAlertTableSchema()
{
    table="alert"
    echo "disable '$table'"
    echo "drop '$table'"
    echo "create '$table', {NAME=>'f', VERSIONS=>1, TTL => 'FOREVER', COMPRESSION => 'SNAPPY', BLOCKCACHE => 'true'}"
}

printTableSchema()
{
    table="$1"
    echo "disable '$table'"
    echo "drop '$table'"
    echo "create '$table', {NAME=>'f', VERSIONS=>1, TTL => 'FOREVER', COMPRESSION => 'SNAPPY', BLOCKCACHE => 'true'}"
}

createSchema()
{
    printTableSchema "metric"|hbase shell
    printTableSchema "alert"|hbase shell
    printTableSchema "server_state"|hbase shell
}

start()
{
    nohup spark-submit \
    --master "yarn" \
    --deploy-mode "client" \
    --num-executors "${spark.num.executors}" \
    --executor-cores "${spark.executor.cores}" \
    --class "$BDP_STREAM_MAIN_CLASS" \
    --driver-class-path "$BDP_STREAM_CONF_DIR" \
    --driver-java-options "-Dlog4j.configuration=log4j-driver.properties -Duser.timezone=Asia/Shanghai" \
    --files "file://$BDP_STREAM_CONF_DIR/bdp-stream.conf,file://$BDP_STREAM_CONF_DIR/log4j-executor.properties,file://$BDP_STREAM_CONF_DIR/hbase-site.xml" \
    --conf "spark.sql.warehouse.dir=/user/bdp-stream/spark-warehouse" \
    --conf "spark.sql.shuffle.partitions=${spark.sql.shuffle.partitions}" \
    --conf "spark.streaming.concurrentJobs=${spark.streaming.concurrentJobs}" \
    --conf "spark.scheduler.mode=${spark.scheduler.mode}" \
    --conf "spark.scheduler.allocation.file=$BDP_STREAM_CONF_DIR/fairscheduler.xml" \
    --conf "spark.executor.extraJavaOptions=-Duser.timezone=Asia/Shanghai -Dlog4j.configuration=log4j-executor.properties" \
    --conf "spark.logConf=true" \
    --jars "$BDP_STREAM_DEPENDENCY_JARS" \
    "$BDP_STREAM_LIB_DIR/$BDP_STREAM_JAR" >${app.log.home}/${project.artifactId}.out 2>&1 &

    echo $! > "$BDP_STREAM_PID"
}

stop()
{
    if [ -f $BDP_STREAM_PID ]; then
        # kill -0 == see if the PID exists
        if kill -0 `cat $BDP_STREAM_PID` > /dev/null 2>&1; then
            kill -9 `cat $BDP_STREAM_PID` > /dev/null 2>&1
        fi
    fi
}

restart()
{
    stop
    sleep 5
    start
}

status()
{
    etime=$(ps -eo etime,cmd | grep spark | grep --color=NEVER $BDP_STREAM_MAIN_CLASS | awk '{print $1}')
    if [ "$etime" == "" ]
    then
        echo -e "${project.artifactId} is not running!"
    else
        echo -e "${project.artifactId} has been running for $etime ([[DD-]hh:]mm:ss) !"
    fi
}

showPs()
{
    pid=$(ps -eo pid,cmd | grep spark | grep --color=NEVER $BDP_STREAM_MAIN_CLASS | awk '{print $1}')
    if [ "$pid" == "" ]
    then
        echo -e "${project.artifactId} is not running!"
    else
        ps -f $pid
    fi
}

tailLog()
{
    tail -F -n 0 ${app.log.home}/spark-driver.log
}

cleanLog()
{
    for node in ${BDP_STREAM_CLUSTER_NODES[@]}
    do
        ssh -T $node <<EOF
        rm -rf ${app.log.home}/*
EOF
    done
}

reloadMetadata()
{
    for node in ${BDP_STREAM_CLUSTER_NODES[@]}
    do
        if [ "$node" != "${app.host}" ]
        then
            curl http://$node:9999/metadata
        fi
    done
}

restartWithLogging()
{
    stop
    sleep 5
    cleanLog
    start
    tailLog
}

# -----------------------------------------------   Shell Scripts Entry   -------------------------------------------- #

case $1 in
    (create-schema)
        createSchema
    ;;
    (start)
        start
    ;;
    (stop)
        stop
    ;;
    (restart)
        restart
    ;;
    (status)
        status
    ;;
    (show-ps)
        showPs
    ;;
    (tail-log)
        tailLog
    ;;
    (clean-log)
        cleanLog
    ;;
    (restart-with-logging)
        restartWithLogging
    ;;
    (reload-metadata)
        reloadMetadata
    ;;
    (*)
        showUsage
    ;;
esac
