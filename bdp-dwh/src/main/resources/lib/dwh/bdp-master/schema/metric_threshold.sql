-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dwh.bdp_master_metric_threshold;
create table if not exists dwh.bdp_master_metric_threshold (
    server_id bigint,
    metric_name string,
    amber_threshold int,
    red_threshold int,
    creation_time timestamp,
    update_time timestamp,
    imported_time timestamp
)
stored as parquet;
