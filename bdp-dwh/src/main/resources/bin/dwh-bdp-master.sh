#!/usr/bin/env bash

export BDP_DWH_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"
export DWH_BDP_MASTER_HOME="$BDP_DWH_HOME/lib/dwh/bdp-master"
export SUBJECT="dwh :: bdp-master"
export UNDER_LAYER_SUBJECT="src :: bdp-master"

source "$BDP_DWH_HOME/bin/util.sh"
source "$DWH_BDP_MASTER_HOME/bin/spark-actions.sh"

# ------------------------------------------------   Common Methods   ------------------------------------------------ #

showUsage()
{
    printHeading "MODULE: [ $(echo "$SUBJECT" | tr 'a-z' 'A-Z') ] USAGE"

    echo "# 说明：创建app 表的schema"
    echo "$0 create-app "
    echo

    echo "# 说明：从src导入指定时间范围内的app数据到dwh"
    echo "$0 build-app START_TIME END_TIME"
    echo

    echo "# 示例：从src导入2018-09-01的app数据到dwh"
    echo "$0 build-app '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建server表的schema"
    echo "$0 create-server"
    echo

    echo "# 说明：从src导入指定时间范围内的server数据到dwh"
    echo "$0 build-server START_TIME END_TIME"
    echo

    echo "# 示例：从src导入2018-09-01的server数据到dwh"
    echo "$0 build-server '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建metric-index表的schema"
    echo "$0 create-metric-index"
    echo

    echo "# 说明：从src导入指定时间范围内的metric-index数据到dwh"
    echo "$0 build-metric-index START_TIME END_TIME"
    echo

    echo "# 示例：从src导入2018-09-01的metric-index数据到dwh"
    echo "$0 build-metric-index '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建metric-threshold表的schema"
    echo "$0 create-metric-threshold"
    echo

    echo "# 说明：从src导入指定时间范围内的metric-threshold数据到dwh"
    echo "$0 build-metric-threshold START_TIME END_TIME"
    echo

    echo "# 示例：从src导入2018-09-01的metric-threshold数据到dwh"
    echo "$0 build-metric-threshold '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo
}

# ----------------------------------------------    Scripts Entrance    ---------------------------------------------- #

case $1 in
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
