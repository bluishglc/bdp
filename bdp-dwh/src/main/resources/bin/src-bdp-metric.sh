#!/usr/bin/env bash

export BDP_DWH_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"
export SRC_BDP_METRIC_HOME="$BDP_DWH_HOME/lib/src/bdp-metric"
export SUBJECT="src :: bdp-metric"
export UNDER_LAYER_SUBJECT="tmp :: bdp-metric"

source "$BDP_DWH_HOME/bin/util.sh"
source "$SRC_BDP_METRIC_HOME/bin/sqoop-actions.sh"
source "$SRC_BDP_METRIC_HOME/bin/spark-actions.sh"

# ------------------------------------------------   Common Methods   ------------------------------------------------ #

showUsage()
{
    printHeading "MODULE: [ $(echo "$SUBJECT" | tr 'a-z' 'A-Z') ] USAGE"

    echo "# 说明：创建metric表的schema"
    echo "$0 create-metric"
    echo

    echo "# 说明：从数据源导入指定时间范围内的metric数据到src"
    echo "$0 build-metric START_TIME END_TIME"
    echo

    echo "# 示例：从数据源导入2018-09-01的metric数据到src"
    echo "$0 build-metric '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo
}

# ----------------------------------------------    Scripts Entrance    ---------------------------------------------- #

case $1 in
    (create-metric)
        createMetricToTmp
        createMetric
    ;;
    (build-metric)
        shift
        buildMetricToTmp "$@"
        buildMetric "$@"
    ;;
    (help)
        showUsage
    ;;
    (*)
        showUsage
    ;;
esac
