-- noinspection SqlNoDataSourceInspectionForFile

insert overwrite table src.bdp_master_app partition(update_date)
select
    id,
    name,
    description,
    version,
    cast(creation_time as timestamp) as creation_time,
    cast(update_time as timestamp) as update_time,
    current_timestamp as imported_time,
    cast(cast(`update_time` as date) as string) as update_date
from
    tmp.bdp_master_app;

