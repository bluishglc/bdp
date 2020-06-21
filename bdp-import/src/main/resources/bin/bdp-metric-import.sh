#!/usr/bin/env bash

export BDP_IMPORT_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"
export SUBJECT="bdp-metric-import"

source "$BDP_IMPORT_HOME/bin/util.sh"

# ------------------------------------------------   Common Methods   ------------------------------------------------ #

showUsage()
{
    printHeading "MODULE: [ $(echo "$SUBJECT" | tr 'a-z' 'A-Z') ] USAGE"

    echo "# 说明：创建metric表的schema，并从数据源导入指定时间范围内的metric数据到tmp的对应表"
    echo "$0 init-metric"
    echo

    echo "# 示例：创建metric表的schema，并从数据源导入2018-09-01的metric数据到tmp的对应表"
    echo "$0 init-metric '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建metric表的schema"
    echo "$0 create-metric"
    echo

    echo "# 说明：从数据源导入指定时间范围内的metric数据到tmp的对应表"
    echo "$0 import-metric START_TIME END_TIME"
    echo

    echo "# 示例：从数据源导入2018-09-01的metric数据到tmp的对应表"
    echo "$0 import-metric '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo
}

# ------------------------------------------------    Major Methods   ------------------------------------------------ #

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

importToTmp()
{
    srcTable="$1"
    sinkTable="$2"
    splitColumn="$3"
    validateTime "$4"
    validateTime "$5"
    startTime=$(date -d "$4" +"%F %T")
    endTime=$(date -d "$5" +"%F %T")
    sinkTablePath="$TMP_DATA_BASE_DIR/$sinkTable/"
    jobName="subject: $SUBJECT -- import [ $srcTable ] data from data source to tmp layer via sqoop"

    printHeading "${jobName}"

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

importMetricToTmp()
{
    importToTmp "metric" "tmp.bdp_metric_metric" "id" "$1" "$2"
}

# ----------------------------------------------    Scripts Entrance    ---------------------------------------------- #

case $1 in
    (init-all)
        createMetricToTmp
        shift
        importMetricToTmp "$@"
    ;;
    (create-all)
        createMetricToTmp
    ;;
    (import-all)
        shift
        importMetricToTmp "$@"
    ;;
    (init-metric)
        createMetricToTmp
        shift
        importMetricToTmp "$@"
    ;;
    (create-metric)
        createMetricToTmp
    ;;
    (import-metric)
        shift
        importMetricToTmp "$@"
    ;;
    (help)
        showUsage
    ;;
    (*)
        showUsage
    ;;
esac
