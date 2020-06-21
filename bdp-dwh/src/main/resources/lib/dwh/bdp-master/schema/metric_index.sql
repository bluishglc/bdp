-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dwh.bdp_master_metric_index;
create table if not exists dwh.bdp_master_metric_index (
    id bigint,
    name string,
    description string,
    category string,
    creation_time timestamp,
    update_time timestamp,
    imported_time timestamp
)
stored as parquet;