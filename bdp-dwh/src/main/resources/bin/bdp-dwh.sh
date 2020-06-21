#!/usr/bin/env bash

export BDP_DWH_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"

source "$BDP_DWH_HOME/bin/util.sh"

# ------------------------------------------------   Common Methods   ------------------------------------------------ #

showUsage()
{
    showLocalUsage
    $BDP_DWH_HOME/bin/src-bdp-master.sh help
    $BDP_DWH_HOME/bin/dwh-bdp-master.sh help
    $BDP_DWH_HOME/bin/dmt-master-data.sh help
    $BDP_DWH_HOME/bin/src-bdp-metric.sh help
    $BDP_DWH_HOME/bin/dwh-bdp-metric.sh help
    $BDP_DWH_HOME/bin/dmt-infra-metric.sh help
}

showLocalUsage()
{
    printHeading "PROJECT [ BDP-DWH ] USAGE"
    
    echo "# 说明：创建所有表的schema"
    echo "$0 create-all"
    echo

    echo "# 说明：从数据源导入指定时间范围内的所有数据，执行数仓各个分层上的所有操作"
    echo "$0 build-all START_TIME END_TIME"
    echo

    echo "# 示例：从数据源导入2018-09-01的所有数据，执行数仓各个分层上的所有操作"
    echo "$0 build-all '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：显示数据库中的所有数据表（限定10条）"
    echo "$0 show-data"
    echo

    echo "# 说明：清空数据库中的所有数据表"
    echo "$0 truncate-all"
    echo

    echo "# 说明：使用应用配置开启spark-sql控制台"
    echo "$0 spark-sql"
    echo

    echo "# 说明：创建_在数仓各层上对应表的schema"
    echo "$0 create-hour"
    echo

    echo "# 说明：从TMP到DMT逐层构建hour对应表的数据"
    echo "$0 build-hour"
    echo

    echo "# 说明：创建app在数仓各层上对应表的schema"
    echo "$0 create-app"
    echo

    echo "# 说明：按指定的日期范围，从TMP到DMT逐层构建app对应表的数据"
    echo "$0 build-app START_TIME END_TIME"
    echo

    echo "# 示例：构建2018-09-01这一天从TMP到DMT各层app数据"
    echo "$0 build-app '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建server在数仓各层上对应表的schema"
    echo "$0 create-server"
    echo

    echo "# 说明：按指定的日期范围，从TMP到DMT逐层构建server对应表的数据"
    echo "$0 build-server START_TIME END_TIME"
    echo

    echo "# 示例：构建2018-09-01这一天从TMP到DMT各层server数据"
    echo "$0 build-server '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建metric_index在数仓各层上对应表的schema"
    echo "$0 create-metric-index"
    echo

    echo "# 说明：按指定的日期范围，从TMP到DMT逐层构建metric_index对应表的数据"
    echo "$0 build-metric-index START_TIME END_TIME"
    echo

    echo "# 示例：构建2018-09-01这一天从TMP到DMT各层metric_index数据"
    echo "$0 build-metric-index '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建metric_threshold在数仓各层上对应表的schema"
    echo "$0 create-metric-threshold"
    echo

    echo "# 说明：按指定的日期范围，从TMP到DMT逐层构建metric_threshold对应表的数据"
    echo "$0 build-metric-threshold START_TIME END_TIME"
    echo

    echo "# 示例：构建2018-09-01这一天从TMP到DMT各层metric_threshold数据"
    echo "$0 build-metric-threshold '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建metric在数仓各层上对应表的schema"
    echo "$0 create-metric"
    echo

    echo "# 说明：按指定的日期范围，从TMP到DMT逐层构建metric对应表的数据"
    echo "$0 build-metric START_TIME END_TIME"
    echo

    echo "# 示例：构建2018-09-01这一天从TMP到DMT各层metric数据"
    echo "$0 build-metric '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo
}

# ------------------------------------------------    Major Methods   ------------------------------------------------ #

initAll()
{
    createAll
    buildAll "$@"
}

createAll()
{
    createHour
    createApp
    createServer
    createMetricIndex
    createMetricThreshold
    createMetric
}

buildAll()
{
    buildHour
    buildApp "$@"
    buildServer "$@"
    buildMetricIndex "$@"
    buildMetricThreshold "$@"
    buildMetric "$@"
}

createHour()
{
    $BDP_DWH_HOME/bin/dmt-master-data.sh create-hour
}

buildHour()
{
    $BDP_DWH_HOME/bin/dmt-master-data.sh build-hour
}

createApp()
{
    $BDP_DWH_HOME/bin/src-bdp-master.sh create-app
    $BDP_DWH_HOME/bin/dwh-bdp-master.sh create-app
    $BDP_DWH_HOME/bin/dmt-master-data.sh create-app
}

buildApp()
{
    $BDP_DWH_HOME/bin/src-bdp-master.sh build-app "$@"
    $BDP_DWH_HOME/bin/dwh-bdp-master.sh build-app "$@"
    $BDP_DWH_HOME/bin/dmt-master-data.sh build-app "$@"
}

createServer()
{
    $BDP_DWH_HOME/bin/src-bdp-master.sh create-server
    $BDP_DWH_HOME/bin/dwh-bdp-master.sh create-server
    $BDP_DWH_HOME/bin/dmt-master-data.sh create-server
}

buildServer()
{
    $BDP_DWH_HOME/bin/src-bdp-master.sh build-server "$@"
    $BDP_DWH_HOME/bin/dwh-bdp-master.sh build-server "$@"
    $BDP_DWH_HOME/bin/dmt-master-data.sh build-server "$@"
}

createMetricIndex()
{
    $BDP_DWH_HOME/bin/src-bdp-master.sh create-metric-index
    $BDP_DWH_HOME/bin/dwh-bdp-master.sh create-metric-index
    $BDP_DWH_HOME/bin/dmt-master-data.sh create-metric-index
}

buildMetricIndex()
{
    $BDP_DWH_HOME/bin/src-bdp-master.sh build-metric-index "$@"
    $BDP_DWH_HOME/bin/dwh-bdp-master.sh build-metric-index "$@"
    $BDP_DWH_HOME/bin/dmt-master-data.sh build-metric-index "$@"
}

createMetricThreshold()
{
    $BDP_DWH_HOME/bin/src-bdp-master.sh create-metric-threshold
    $BDP_DWH_HOME/bin/dwh-bdp-master.sh create-metric-threshold
    $BDP_DWH_HOME/bin/dmt-master-data.sh create-metric-threshold
}

buildMetricThreshold()
{
    $BDP_DWH_HOME/bin/src-bdp-master.sh build-metric-threshold "$@"
    $BDP_DWH_HOME/bin/dwh-bdp-master.sh build-metric-threshold "$@"
    $BDP_DWH_HOME/bin/dmt-master-data.sh build-metric-threshold "$@"
}

createMetric()
{
    $BDP_DWH_HOME/bin/src-bdp-metric.sh create-metric
    $BDP_DWH_HOME/bin/dwh-bdp-metric.sh create-metric
    $BDP_DWH_HOME/bin/dmt-infra-metric.sh create-fact-metric
    $BDP_DWH_HOME/bin/dmt-infra-metric.sh create-sum-metric-avg
    $BDP_DWH_HOME/bin/dmt-infra-metric.sh create-wide-metric-avg
}

buildMetric()
{
    $BDP_DWH_HOME/bin/src-bdp-metric.sh build-metric "$@"
    $BDP_DWH_HOME/bin/dwh-bdp-metric.sh build-metric "$@"
    $BDP_DWH_HOME/bin/dmt-infra-metric.sh build-fact-metric "$@"
    $BDP_DWH_HOME/bin/dmt-infra-metric.sh build-sum-metric-avg "$@"
    $BDP_DWH_HOME/bin/dmt-infra-metric.sh build-wide-metric-avg "$@"
}

truncateAll()
{
    beeline --color=true --truncateTable=true -u=jdbc:hive2://${cluster.hiverserver}:10000 -n ${app.user.name} -e "\
    truncate table src.bdp_metric_metric;
    truncate table src.bdp_master_app;
    truncate table src.bdp_master_server;
    truncate table src.bdp_master_metric_index;
    truncate table src.bdp_master_metric_threshold;
    truncate table dwh.bdp_metric_metric;
    truncate table dwh.bdp_master_app;
    truncate table dwh.bdp_master_server;
    truncate table dwh.bdp_master_metric_index;
    truncate table dwh.bdp_master_metric_threshold;
    truncate table dmt.dim_app;
    truncate table dmt.dim_server;
    truncate table dmt.dim_metric_index;
    truncate table dmt.dim_metric_threshold;
    truncate table dmt.fact_metric;
    truncate table dmt.sum_metric_avg;
    truncate table dmt.wide_metric_avg;"
}

showData()
{
    beeline --color=true --truncateTable=true -u=jdbc:hive2://${cluster.hiverserver}:10000 -n ${app.user.name} -e "\
    select * from src.bdp_metric_metric limit 10;
    select * from src.bdp_master_app;
    select * from src.bdp_master_server;
    select * from src.bdp_master_metric_index;
    select * from src.bdp_master_metric_threshold;
    select * from dwh.bdp_metric_metric limit 10;
    select * from dwh.bdp_master_app;
    select * from dwh.bdp_master_server;
    select * from dwh.bdp_master_metric_index;
    select * from dwh.bdp_master_metric_threshold;
    select * from dmt.dim_app;
    select * from dmt.dim_server;
    select * from dmt.dim_metric_index;
    select * from dmt.dim_metric_threshold;
    select * from dmt.dim_hour limit 10;
    select * from dmt.fact_metric limit 10;
    select * from dmt.sum_metric_avg limit 10;
    select * from dmt.wide_metric_avg limit 10;"
}

# ----------------------------------------------    Scripts Entrance    ---------------------------------------------- #

case $1 in
    (init-all)
        createAll
        shift
        buildAll "$@"
    ;;
    (create-all)
        createAll
    ;;
    (truncate-all)
        truncateAll
    ;;
    (build-all)
        shift
        buildAll "$@"
    ;;
    (create-hour)
        createHour
    ;;
    (build-hour)
        shift
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
    (create-metric)
        createMetric
    ;;
    (build-metric)
        shift
        buildMetric "$@"
    ;;
    (show-data)
        showData
    ;;
    (spark-sql)
        sparkSql
    ;;
    (help)
        showUsage
    ;;
    (*)
        showUsage
    ;;
esac
