#!/usr/bin/env bash

createToTmp()
{
    srcTable="$1"
    sinkTable="$2"
    printHeading "job name: create table ${sinkTable}"

    sqoop create-hive-table \
    -D mapred.job.name="job name: create table [$sinkTable]" \
    --connect '${bdp.metric.jdbc.url}' \
    --username '${bdp.metric.jdbc.user}' \
    --password '${bdp.metric.jdbc.password}' \
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
    --connect '${bdp.metric.jdbc.url}' \
    --username '${bdp.metric.jdbc.user}' \
    --password '${bdp.metric.jdbc.password}' \
    --table "$srcTable" \
    --where "timestamp between '$startTime' and '$endTime'" \
    --split-by "$splitColumn" \
    --hive-import \
    --hive-overwrite \
    --hive-table "$sinkTable" \
    --target-dir "$sinkTablePath" \
    --outdir "/tmp" \
    --delete-target-dir
}

createMetricToTmp()
{
    createToTmp "metric" "tmp.bdp_metric_metric"
}

buildMetricToTmp()
{
    buildToTmp "metric" "tmp.bdp_metric_metric" "id" "$1" "$2"
}