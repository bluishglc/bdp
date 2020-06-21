-- noinspection SqlNoDataSourceInspectionForFile
insert overwrite table dmt.wide_metric_avg partition(creation_date)
select
    a.dwid as app_dwid,
    a.name as app_name,
    a.description as app_description,
    a.version as app_version,
    s.dwid as server_dwid,
    s.hostname as server_hostname,
    s.cpu_cores as server_cpu_cores,
    s.memory as server_memory,
    m.dwid as metric_index_dwid,
    m.name as metric_name,
    m.description as metric_description,
    m.category as metric_category,
    t.dwid as metric_threshold_dwid,
    t.amber_threshold as amber_threshold,
    t.red_threshold as red_threshold,
    h.dwid as hour_dwid,
    h.db_date as db_date,
    h.db_hour as db_hour,
    h.year as year,
    h.month as month,
    h.day as day,
    h.hour as hour,
    h.quarter as quarter,
    h.week as week,
    h.day_name as day_name,
    h.month_name as month_name,
    h.weekend_flag as weekend_flag,
    avg_value,
    rag,
    creation_date
from dmt.sum_metric_avg ma
join dmt.dim_app a on a.dwid = ma.app_dwid
join dmt.dim_server s on s.dwid = ma.server_dwid
join dmt.dim_metric_index m on m.dwid = ma.metric_index_dwid
join dmt.dim_metric_threshold t on t.server_id = s.id and t.metric_name = m.name
join dmt.dim_hour h on h.dwid = ma.hour_dwid
where ma.creation_date >= '@startDate@' and ma.creation_date < '@endDate@';