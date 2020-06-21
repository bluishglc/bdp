-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dmt.dim_metric_index;
create table if not exists dmt.dim_metric_index (
    dwid bigint,
    id bigint,
    name string,
    description string,
    category string,
    valid_from timestamp,
    valid_to timestamp,
    eff_flag boolean
)
stored as parquet;