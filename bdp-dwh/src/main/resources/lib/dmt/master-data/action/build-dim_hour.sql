-- noinspection SqlNoDataSourceInspectionForFile

insert overwrite table dmt.dim_hour
select
    dwid,
    db_date,
    db_hour,
    year,
    month,
    day,
    hour,
    quarter,
    week,
    day_name,
    month_name,
    weekend_flag
from
    tmp.dim_hour;