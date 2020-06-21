#!/usr/bin/env bash

create()
{
    target="$1"
    execSql "job name: create schema of [ $target @ $SUBJECT ]" "$DMT_INFRA_METRIC_HOME/schema/$target.sql"
}

build()
{
    target="$1"
    validateTime "$2"
    validateTime "$3"

    startDate=$(date -d "$2" +"%F")
    endDate=$(date -d "$3" +"%F")
    template="build-$target.sql"

    sed "s/@startDate@/$startDate/g" "$DMT_INFRA_METRIC_HOME/action/$template" | \
    sed "s/@endDate@/$endDate/g" > "$DMT_INFRA_METRIC_HOME/action/.$template"

    execSql "job name: build [ $target ] data from [ $target @ $UNDER_LAYER_SUBJECT ] to [ $target @ $SUBJECT ]" \
        "$DMT_INFRA_METRIC_HOME/action/.$template"
}

createFactMetric()
{
    create "fact_metric"
}

buildFactMetric()
{
    build "fact_metric" "$1" "$2"
}

createSumMetricAvg()
{
    create "sum_metric_avg"

}

buildSumMetricAvg()
{
    build "sum_metric_avg" "$1" "$2"
}

createWideMetricAvg()
{
    create "wide_metric_avg"

}

buildWideMetricAvg()
{
    build "wide_metric_avg" "$1" "$2"
}

