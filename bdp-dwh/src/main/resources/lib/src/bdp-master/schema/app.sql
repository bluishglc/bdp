-- noinspection sqlnodatasourceinspectionforfile

drop table if exists src.bdp_master_app;
create table if not exists src.bdp_master_app (
    id bigint,
    name string,
    description string,
    version string,
    creation_time timestamp,
    update_time timestamp,
    imported_time timestamp
)
partitioned by (update_date string)
stored as parquet;
