#!/usr/bin/env bash

create()
{
    target="$1"
    execSql "job name: create schema of [ $target @ $SUBJECT ]" "${SRC_BDP_MASTER_HOME}/schema/$target.sql"
}

build()
{
    target="$1"
    execSql "job name: build [ $target ] data from [ $target @ $UNDER_LAYER_SUBJECT ] to [ $target @ $SUBJECT ]" "${SRC_BDP_MASTER_HOME}/action/build-$target.sql"
}

createApp()
{
    create "app"
}

buildApp()
{
    build "app"
}

createServer()
{
    create "server"
}

buildServer()
{
    build "server"
}

createMetricIndex()
{
    create "metric_index"
}

buildMetricIndex()
{
    build "metric_index"
}

createMetricThreshold()
{
    create "metric_threshold"
}

buildMetricThreshold()
{
    build "metric_threshold"
}