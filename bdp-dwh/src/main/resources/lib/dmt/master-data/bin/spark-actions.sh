#!/usr/bin/env bash

create()
{
    target="$1"
    execSql "job name:  create schema of [ $target @ $SUBJECT ]" "$DMT_MASTER_DATA_HOME/schema/$target.sql"
}

build()
{
    target="$1"
    validateTime "$2"
    validateTime "$3"

    startDate=$(date -d "$2" +"%F")
    endDate=$(date -d "$3" +"%F")
    template="build-$target.sql"

    sed "s/@startDate@/$startDate/g" "$DMT_MASTER_DATA_HOME/action/$template" | \
    sed "s/@endDate@/$endDate/g" > "$DMT_MASTER_DATA_HOME/action/.$template"

    execSql "job name: build [ $target ] data from [ $target @ $UNDER_LAYER_SUBJECT ] to [ $target @ $SUBJECT ]" \
        "$DMT_MASTER_DATA_HOME/action/.$template"
}

createApp()
{
    create "dim_app"
}

buildApp()
{
    build "dim_app" "$1" "$2"
}

createServer()
{
    create "dim_server"
}

buildServer()
{
    build "dim_server" "$1" "$2"
}

createMetricIndex()
{
    create "dim_metric_index"
}

buildMetricIndex()
{
    build "dim_metric_index" "$1" "$2"
}

createMetricThreshold()
{
    create "dim_metric_threshold"
}

buildMetricThreshold()
{
    build "dim_metric_threshold" "$1" "$2"
}

createHour()
{
    create "dim_hour"
}

buildHour()
{
    # put data dimension data file onto HDFS.
    template="build-dim_hour.sql"
    dimHourLocalPath="$DMT_MASTER_DATA_HOME/data/dim_hour.csv"
    dimHourHdfsDir="/data/tmp/dim_hour"
    hdfs dfs -test -d $dimHourHdfsDir && hdfs dfs -rm -r -f -skipTrash $dimHourHdfsDir
    hdfs dfs -mkdir -p $dimHourHdfsDir
    dimHourHdfsPath="$dimHourHdfsDir/dim_hour.csv"
    target="dim_hour"

    hdfs dfs -put -f $dimHourLocalPath $dimHourHdfsPath
    execSql "job name: build [ $target ] data for [ $SUBJECT ], data flow: [ $target @ $dimHourLocalPath -> $target @ $SUBJECT ]" "$DMT_MASTER_DATA_HOME/action/$template"
}
