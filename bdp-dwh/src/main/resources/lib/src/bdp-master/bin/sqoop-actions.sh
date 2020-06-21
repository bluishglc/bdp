#!/usr/bin/env bash

createToTmp()
{
    srcTable="$1"
    sinkTable="$2"
    printHeading "job name: create table ${sinkTable}"

    sqoop create-hive-table \
    -D mapred.job.name="job name: create table [$sinkTable]" \
    --connect '${bdp.master.jdbc.url}' \
    --username '${bdp.master.jdbc.user}' \
    --password '${bdp.master.jdbc.password}' \
    --table "$srcTable" \
    --hive-table "$sinkTable" \
    --hive-overwrite
}

buildToTmp()
{
    srcTable="$1"
    sinkTable="$2"
    splitColumn="$3"
    validateTime "$4"
    validateTime "$5"

    jobName="subject: $SUBJECT -- build [ $srcTable ] data from data source to tmp layer via sqoop"

    printHeading "${jobName}"

    startTime=$(date -d "$4" +"%F %T")
    endTime=$(date -d "$5" +"%F %T")

    sinkTablePath="$TMP_DATA_BASE_DIR/$sinkTable/"

    sqoop import \
    -D mapred.job.name="${jobName}" \
    --connect '${bdp.master.jdbc.url}' \
    --username '${bdp.master.jdbc.user}' \
    --password '${bdp.master.jdbc.password}' \
    --table "$srcTable" \
    --where "update_time between '$startTime' and '$endTime'" \
    --split-by "$splitColumn" \
    --hive-import \
    --hive-overwrite \
    --hive-table "$sinkTable" \
    --target-dir "$sinkTablePath" \
    --outdir "/tmp" \
    --delete-target-dir
}

createAppToTmp()
{
    createToTmp "app" "tmp.bdp_master_app"
}

buildAppToTmp()
{
    buildToTmp "app" "tmp.bdp_master_app" "id" "$1" "$2"
}

createServerToTmp()
{
    createToTmp "server" "tmp.bdp_master_server"
}

buildServerToTmp()
{
    buildToTmp "server" "tmp.bdp_master_server" "id" "$1" "$2"
}

createMetricIndexToTmp()
{
    createToTmp "metric_index" "tmp.bdp_master_metric_index"
}

buildMetricIndexToTmp()
{
    buildToTmp "metric_index" "tmp.bdp_master_metric_index" "id" "$1" "$2"
}

createMetricThresholdToTmp()
{
    createToTmp "metric_threshold" "tmp.bdp_master_metric_threshold"
}

buildMetricThresholdToTmp()
{
    buildToTmp "metric_threshold" "tmp.bdp_master_metric_threshold" "server_id" "$1" "$2"
}
