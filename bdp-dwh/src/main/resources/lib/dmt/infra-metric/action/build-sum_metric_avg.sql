-- noinspection SqlNoDataSourceInspectionForFile
create temporary function gen_rag as 'com.github.bdp.dwh.udf.GenRag' using jar '${app.home}/jar/${project.build.finalName}.jar';

insert overwrite table dmt.sum_metric_avg partition(creation_date)
select
    ma.app_dwid,
    ma.server_dwid,
    ma.metric_index_dwid,
    t.dwid,
    ma.hour_dwid,
    ma.avg_value,
    gen_rag(ma.avg_value, t.amber_threshold, t.red_threshold) as rag,
    ma.creation_date
from (
    select
        m.app_dwid,
        m.server_dwid,
        m.metric_index_dwid,
        m.hour_dwid,
        cast(round(avg(m.`value`)) as int) as avg_value,
        m.creation_date
    from dmt.fact_metric m
    where m.creation_date >= '@startDate@' and m.creation_date < '@endDate@'
    group by m.creation_date,m.app_dwid, m.server_dwid, m.metric_index_dwid, m.hour_dwid
) ma
join dmt.dim_server s on s.dwid = ma.server_dwid
join dmt.dim_metric_index dm on dm.dwid = ma.metric_index_dwid
join dmt.dim_metric_threshold t on t.server_id = s.id and t.metric_name = dm.name
where
    cast(ma.creation_date as timestamp) >= s.valid_from and (cast(ma.creation_date as timestamp) < s.valid_to or s.valid_to is null) and
    cast(ma.creation_date as timestamp) >= dm.valid_from and (cast(ma.creation_date as timestamp) < dm.valid_to or dm.valid_to is null) and
    cast(ma.creation_date as timestamp) >= t.valid_from and (cast(ma.creation_date as timestamp) < t.valid_to or t.valid_to is null);