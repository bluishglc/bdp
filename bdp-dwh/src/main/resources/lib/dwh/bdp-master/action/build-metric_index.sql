-- noinspection SqlNoDataSourceInspectionForFile
-- move consolidated data back to original table.

set spark.sql.hive.convertMetastoreParquet=false;
set spark.sql.parser.quotedRegexColumnNames=true;

insert overwrite table dwh.bdp_master_metric_index
select
    `(row_num|oc)?+.+`
from (
    select
        *,
        row_number () over (
            partition by id
            order by update_time desc, oc desc
        ) as row_num
    from (
        select
            *, 0 as oc
        from
            dwh.bdp_master_metric_index
        union all
        select
            `(update_date)?+.+`, 1 as oc
        from
            src.bdp_master_metric_index
        where
            update_date >= '@startDate@' and update_date < '@endDate@'
    )a
)
where row_num = 1;