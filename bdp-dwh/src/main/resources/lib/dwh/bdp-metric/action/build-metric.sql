-- noinspection SqlNoDataSourceInspectionForFile

insert overwrite table dwh.bdp_metric_metric partition(creation_date)
select
    id,
    name,
    hostname,
    value,
    cast(`timestamp` as timestamp),
    imported_time,
    cast(cast(`timestamp` as date) as string) as creation_date
from
    src.bdp_metric_metric
where
    creation_date >= '@startDate@' and creation_date < '@endDate@';