-- noinspection SqlNoDataSourceInspectionForFile

insert overwrite table src.bdp_master_server partition(update_date)
select
    id,
    app_id,
    hostname,
    cpu_cores,
    memory,
    cast(creation_time as timestamp) as creation_time,
    cast(update_time as timestamp) as update_time,
    current_timestamp as imported_time,
    cast(cast(`update_time` as date) as string) as update_date
from
    tmp.bdp_master_server;

