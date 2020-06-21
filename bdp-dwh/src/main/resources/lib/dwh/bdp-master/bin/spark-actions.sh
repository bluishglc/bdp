#!/usr/bin/env bash

create()
{
    target="$1"
    execSql "job name: create schema of [ $target @ $SUBJECT ]" "${DWH_BDP_MASTER_HOME}/schema/$target.sql"
}

build()
{
    target="$1"
    validateTime "$2"
    validateTime "$3"

    startDate=$(date -d "$2" +"%F")
    endDate=$(date -d "$3" +"%F")
    template="build-$target.sql"

    sed "s/@startDate@/$startDate/g" "$DWH_BDP_MASTER_HOME/action/$template" | \
    sed "s/@endDate@/$endDate/g" > "$DWH_BDP_MASTER_HOME/action/.$template"

    execSql "job name: build [ $target ] data from [ $target @ $UNDER_LAYER_SUBJECT ] to [ $target @ $SUBJECT ]" \
        "$DWH_BDP_MASTER_HOME/action/.$template"
}

createApp()
{
    create "app"
}

buildApp()
{
    build "app" "$1" "$2"
}

createServer()
{
    create "server"
}

buildServer()
{
    build "server" "$1" "$2"
}

createMetricIndex()
{
    create "metric_index"
}

buildMetricIndex()
{
    build "metric_index" "$1" "$2"
}

createMetricThreshold()
{
    create "metric_threshold"
}

buildMetricThreshold()
{
    build "metric_threshold" "$1" "$2"
}