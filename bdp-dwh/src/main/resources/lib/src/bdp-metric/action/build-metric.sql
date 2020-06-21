-- noinspection SqlNoDataSourceInspectionForFile

insert overwrite table src.bdp_metric_metric partition(creation_date)
select
    id,
    name,
    hostname,
    value,
    cast(`timestamp` as timestamp) as `timestamp`,
    current_timestamp as imported_time,
    cast(cast(`timestamp` as date) as string) as creation_date
from
    tmp.bdp_metric_metric;