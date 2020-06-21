-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dmt.dim_server;
create table if not exists dmt.dim_server (
    dwid bigint,
    id bigint,
    app_id bigint,
    hostname string,
    cpu_cores int,
    memory int,
    valid_from timestamp,
    valid_to timestamp,
    eff_flag boolean
)
stored as parquet;