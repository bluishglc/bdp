-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dwh.bdp_master_app;
create table if not exists dwh.bdp_master_app (
    id bigint,
    name string,
    description string,
    version string,
    creation_time timestamp,
    update_time timestamp,
    imported_time timestamp
)
stored as parquet;