-- noinspection SqlNoDataSourceInspectionForFile
-- src.bdp_metric_metric or dwh.bdp_metric_metric ??
insert overwrite table dmt.fact_metric partition(creation_date)
select m.id, a.dwid as app_dwid, s.dwid as server_dwid, mi.dwid as metric_index_dwid, d.dwid as hour_dwid, m.`timestamp`, m.value, m.creation_date
from dwh.bdp_metric_metric m
    join dmt.dim_server s on m.hostname = s.hostname
    join dmt.dim_app a on a.id = s.app_id
    join dmt.dim_metric_index mi on mi.name = m.name
    join dmt.dim_hour d on from_unixtime(unix_timestamp(m.`timestamp`),'yyyy-MM-dd HH:00:00') = d.db_hour
where
    m.`timestamp` >= s.valid_from and (m.`timestamp` < s.valid_to or s.valid_to is null) and
    m.`timestamp` >= a.valid_from and (m.`timestamp` < a.valid_to or a.valid_to is null) and
    m.`timestamp` >= mi.valid_from and (m.`timestamp` < mi.valid_to or mi.valid_to is null) and
    m.creation_date >= '@startDate@' and m.creation_date < '@endDate@';