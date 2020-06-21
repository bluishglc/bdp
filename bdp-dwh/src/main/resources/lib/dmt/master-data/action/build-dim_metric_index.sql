-- noinspection SqlNoDataSourceInspectionForFile

set spark.sql.hive.convertMetastoreParquet=false;
set spark.sql.parser.quotedRegexColumnNames=true;

-- 将新增和变更的数据定义为一个独立数据集，便于后续操作中引用
create or replace temporary view updated_and_added_records as
select
    s.`(creation_time|update_time|imported_time)?+.+`
from
    src.bdp_master_metric_index s
where
    s.update_date >='@startDate@' and s.update_date < '@endDate@';

insert overwrite table dmt.dim_metric_index
select
    *
from(
    -- 针对DMT全量表的操作:
    -- 操作1.1: 将DMT全量表中的“更新前的数据”复制到结果集，失效日期取SRC增量表中记录的更新时间，有效标记位置为"false"
    -- 操作1.2: 将DMT全量表中的“变更历史记录”复制到结果集，不做任何修改
    select
        m.`(valid_to|eff_flag)?+.+`,
        -- 如果是“更新前的记录”，失效日期取增量记录里的更新时间，否则沿用全量记录中的原有值
        case when m.eff_flag = true and u.id is not null then
            u.update_date
        else
            m.valid_to
        end as
            valid_to,
        -- 如果是“更新前的记录”，有效标记位置为"false"，否则沿用全量记录中的原有值
        case when m.eff_flag = true and u.id is not null then
            false
        else
            m.eff_flag
        end as
            eff_flag
    from
        dmt.dim_metric_index m
    left join
        updated_and_added_records u
    on
        m.id = u.id
    union all
    -- 操作2: 针对SRC增量表(新增和变更数据集)的操作: 将增量数据复制到结果集，生效日期取增量记录里的更新时间，有效标记位置为"true"
    select
        row_number() over(order by 0) + m.max_id as dwid, -- 在最大ID的基础上累加，生成数仓中的代理主键dwid
        u.`(update_date)?+.+`,
        u.update_date as valid_from, -- 将“更新后的记录”的更新日期作为生效日期
        null as valid_to,
        true as eff_flag -- 有效标记位置为"true"
    from
        updated_and_added_records u
    cross join
        (select coalesce(max(dwid),0) as max_id from dmt.dim_metric_index) m
);