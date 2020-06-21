#!/usr/bin/env bash

create()
{
    target="$1"
    execSql "job name: create schema of [ $target @ $SUBJECT ]" "$DWH_BDP_METRIC_HOME/schema/$target.sql"
}

build()
{
    target="$1"
    validateTime "$2"
    validateTime "$3"

    startDate=$(date -d "$2" +"%F")
    endDate=$(date -d "$3" +"%F")
    template="build-$target.sql"

    sed "s/@startDate@/$startDate/g" "$DWH_BDP_METRIC_HOME/action/$template" | \
    sed "s/@endDate@/$endDate/g" > "$DWH_BDP_METRIC_HOME/action/.$template"

    execSql "job name: build [ $target ] data from [ $target @ $UNDER_LAYER_SUBJECT ] to [ $target @ $SUBJECT ]" \
        "$DWH_BDP_METRIC_HOME/action/.$template"
}

createMetric()
{
    create "metric"
}

buildMetric()
{
    build "metric" "$1" "$2"
}
