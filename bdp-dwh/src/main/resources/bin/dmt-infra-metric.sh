#!/usr/bin/env bash

export BDP_DWH_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"
export DMT_INFRA_METRIC_HOME="$BDP_DWH_HOME/lib/dmt/infra-metric"
export SUBJECT="dmt :: infra-metric"
export UNDER_LAYER_SUBJECT="dwh :: bdp-metric"

source "$BDP_DWH_HOME/bin/util.sh"
source "$DMT_INFRA_METRIC_HOME/bin/spark-actions.sh"

# ------------------------------------------------   Common Methods   ------------------------------------------------ #

showUsage()
{
    printHeading "MODULE: [ $(echo "$SUBJECT" | tr 'a-z' 'A-Z') ] USAGE"

    echo "# 说明：创建metric表的schema"
    echo "$0 create-fact-metric"
    echo

    echo "# 说明：从dwh导入指定时间范围内的metric数据到dmt, 构建metric事实表"
    echo "$0 build-fact-metric START_TIME END_TIME"
    echo

    echo "# 示例：从dwh导入2018-09-01的metric数据到dmt"
    echo "$0 build-fact-metric '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建metric-avg表的schema"
    echo "$0 create-sum-metric-avg"
    echo

    echo "# 说明：基于dmt上指定时间范围内的metric数据构建汇总数据metric-avg"
    echo "$0 build-sum-metric-avg START_TIME END_TIME"
    echo

    echo "# 示例：基于2018-09-01的metric数据数据构建2018-09-01的汇总数据metric-avg"
    echo "$0 build-sum-metric-avg '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建wide-metric-avg表的schema"
    echo "$0 create-wide-metric-avg"
    echo

    echo "# 说明：基于dmt上指定时间范围内的metric数据构建宽表数据wide-metric-avg"
    echo "$0 build-wide-metric-avg START_TIME END_TIME"
    echo

    echo "# 示例：基于2018-09-01的metric数据数据构建2018-09-01的宽表数据metric-avg"
    echo "$0 build-wide-metric-avg '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

}

# ----------------------------------------------    Scripts Entrance    ---------------------------------------------- #

case $1 in
    (create-fact-metric)
        createFactMetric
     ;;
    (build-fact-metric)
        shift
        buildFactMetric "$@"
    ;;
    (create-sum-metric-avg)
        createSumMetricAvg
    ;;
    (build-sum-metric-avg)
        shift
        buildSumMetricAvg "$@"
    ;;
    (create-wide-metric-avg)
        createWideMetricAvg
    ;;
    (build-wide-metric-avg)
        shift
        buildWideMetricAvg "$@"
    ;;
    (help)
        showUsage
    ;;
    (*)
        showUsage
    ;;
esac
