#!/usr/bin/env bash

create()
{
    target="$1"
    execSql "job name: create schema of [ $target @ $SUBJECT ]" "$SRC_BDP_METRIC_HOME/schema/$target.sql"
}

build()
{
    target="$1"
    execSql "job name: build [ $target ] data from [ $target @ $UNDER_LAYER_SUBJECT ] to [ $target @ $SUBJECT ]" "$SRC_BDP_METRIC_HOME/action/build-$target.sql"
}

createMetric()
{
    create "metric"
}

buildMetric()
{
    build "metric"
}
