#!/usr/bin/env bash

export BDP_DWH_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"
export DMT_MASTER_DATA_HOME="$BDP_DWH_HOME/lib/dmt/master-data"
export SUBJECT="dmt :: master-data"
export UNDER_LAYER_SUBJECT="dwh :: bdp-master"

source "$BDP_DWH_HOME/bin/util.sh"
source "$DMT_MASTER_DATA_HOME/bin/spark-actions.sh"

# ------------------------------------------------   Common Methods   ------------------------------------------------ #

showUsage()
{

    printHeading "MODULE: [ $(echo "$SUBJECT" | tr 'a-z' 'A-Z') ] USAGE"

    echo "# 说明：创建dim_hour表的schema"
    echo "$0 create-dim-hour"
    echo

    echo "# 说明：将hour级别的时间维度数据导入到dmt"
    echo "$0 build-dim-hour"
    echo

    echo "# 说明：创建app表的schema"
    echo "$0 create-bdp-metric"
    echo

    echo "# 说明：从src导入指定时间范围内的app数据到dmt, 构建app的缓慢变化维度表"
    echo "$0 build-bdp-metric START_TIME END_TIME"
    echo

    echo "# 示例：从src导入2018-09-01的app数据到dmt"
    echo "$0 build-bdp-metric '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建server表的schema"
    echo "$0 create-server"
    echo

    echo "# 说明：从src导入指定时间范围内的server数据到dmt, 构建server的缓慢变化维度表"
    echo "$0 build-server START_TIME END_TIME"
    echo

    echo "# 示例：从src导入2018-09-01的server数据到dmt"
    echo "$0 build-server '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建metric-index表的schema"
    echo "$0 create-metric-index"
    echo

    echo "# 说明：从src导入指定时间范围内的metric-index数据到dmt, 构建metric-index的缓慢变化维度表"
    echo "$0 build-metric-index START_TIME END_TIME"
    echo

    echo "# 示例：从src导入2018-09-01的metric-index数据到dmt"
    echo "$0 build-metric-index '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建metric-threshold表的schema"
    echo "$0 create-metric-threshold"
    echo

    echo "# 说明：从src导入指定时间范围内的metric-threshold数据到dmt, 构建metric-threshold的缓慢变化维度表"
    echo "$0 build-metric-threshold START_TIME END_TIME"
    echo

    echo "# 示例：从src导入2018-09-01的metric-threshold数据到dmt"
    echo "$0 build-metric-threshold '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

}

# ----------------------------------------------    Scripts Entrance    ---------------------------------------------- #

case $1 in
    (create-hour)
        createHour
    ;;
    (build-hour)
        buildHour
    ;;
    (create-app)
        createApp
    ;;
    (build-app)
        shift
        buildApp "$@"
    ;;
    (create-server)
        createServer
    ;;
    (build-server)
        shift
        buildServer "$@"
    ;;
    (create-metric-index)
        createMetricIndex
    ;;
    (build-metric-index)
        shift
        buildMetricIndex "$@"
    ;;
    (create-metric-threshold)
        createMetricThreshold
    ;;
    (build-metric-threshold)
        shift
        buildMetricThreshold "$@"
    ;;
    (help)
        showUsage
    ;;
    (*)
        showUsage
    ;;
esac
