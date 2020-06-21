-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dwh.bdp_master_server;
create table if not exists dwh.bdp_master_server (
    id bigint,
    app_id bigint,
    hostname string,
    cpu_cores int,
    memory int,
    creation_time timestamp,
    update_time timestamp,
    imported_time timestamp
)
stored as parquet;
