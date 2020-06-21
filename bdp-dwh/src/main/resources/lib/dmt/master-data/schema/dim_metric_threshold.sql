-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dmt.dim_metric_threshold;
create table if not exists dmt.dim_metric_threshold (
    dwid bigint,
    server_id bigint,
    metric_name string,
    amber_threshold int,
    red_threshold int,
    valid_from timestamp,
    valid_to timestamp,
    eff_flag boolean
)
stored as parquet;