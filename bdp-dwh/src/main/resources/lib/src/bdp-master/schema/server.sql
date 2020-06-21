-- noinspection sqlnodatasourceinspectionforfile

drop table if exists src.bdp_master_server;
create table if not exists src.bdp_master_server (
     id bigint,
     app_id bigint,
     hostname string,
     cpu_cores int,
     memory int,
     creation_time timestamp,
     update_time timestamp,
     imported_time timestamp
)
partitioned by (update_date string)
stored as parquet;