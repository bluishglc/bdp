-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dmt.dim_app;
create table if not exists dmt.dim_app (
    dwid bigint,
    id bigint,
    name string,
    description string,
    version string,
    valid_from timestamp,
    valid_to timestamp,
    eff_flag boolean
)
stored as parquet;
