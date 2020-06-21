#!/usr/bin/env bash

export TMP_DATA_BASE_DIR="/data/tmp"
export BDP_DWH_JAR_DIR="$BDP_DWH_HOME/jar"

BDP_DWH_DEPENDENCY_JARS=""
for JAR in $(ls ${BDP_DWH_JAR_DIR})
do
    BDP_DWH_DEPENDENCY_JARS="$BDP_DWH_JAR_DIR/$JAR,$BDP_DWH_DEPENDENCY_JARS"
done
export BDP_DWH_DEPENDENCY_JARS=${BDP_DWH_DEPENDENCY_JARS%,}

# -----------------------------------------------    Public Methods   ------------------------------------------------ #

sparkSql()
{
    spark-sql \
    --master yarn \
    --deploy-mode client \
    --name "$jobName" \
    --num-executors "${spark.num.executors}" \
    --executor-cores "${spark.executor.cores}" \
    --executor-memory "${spark.executor.memory}" \
    --conf spark.sql.warehouse.dir=${app.hdfs.user.home}/spark-warehouse \
    --conf spark.sql.crossJoin.enabled=true \
    --conf spark.sql.shuffle.partitions=8 \
    --hiveconf hive.metastore.execute.setugi=true \
    --hiveconf hive.exec.dynamic.partition=true \
    --hiveconf hive.exec.dynamic.partition.mode=nonstrict \
    --hiveconf hive.exec.max.dynamic.partitions=10000 \
    --hiveconf hive.exec.max.dynamic.partitions.pernode=10000 \
    --hiveconf hive.mapred.supports.subdirectories=true \
    --hiveconf mapreduce.input.fileinputformat.input.dir.recursive=true \
    --jars "$BDP_DWH_DEPENDENCY_JARS"
}

# -----------------------------------------------   Private Methods   ------------------------------------------------ #

execSql()
{
    jobName="$1"
    sqlFile="$2"
    printHeading "${jobName}"
    spark-sql \
    --master yarn \
    --deploy-mode client \
    --name "$jobName" \
    --num-executors "${spark.num.executors}" \
    --executor-cores "${spark.executor.cores}" \
    --executor-memory "${spark.executor.memory}" \
    --conf spark.sql.warehouse.dir=${app.hdfs.user.home}/spark-warehouse \
    --conf spark.sql.crossJoin.enabled=true \
    --hiveconf hive.metastore.execute.setugi=true \
    --hiveconf hive.exec.dynamic.partition=true \
    --hiveconf hive.exec.dynamic.partition.mode=nonstrict \
    --hiveconf hive.exec.max.dynamic.partitions=10000 \
    --hiveconf hive.exec.max.dynamic.partitions.pernode=10000 \
    --hiveconf hive.mapred.supports.subdirectories=true \
    --hiveconf mapreduce.input.fileinputformat.input.dir.recursive=true \
    --jars "$BDP_DWH_DEPENDENCY_JARS" \
    -f "$sqlFile"
}

printHeading()
{
    title="$1"
    paddingWidth=$((($(tput cols)-${#title})/2-3))
    printf "\n%${paddingWidth}s"|tr ' ' '='
    printf "  $title  "
    printf "%${paddingWidth}s\n\n"|tr ' ' '='
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
