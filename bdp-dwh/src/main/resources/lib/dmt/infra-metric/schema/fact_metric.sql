-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dmt.fact_metric;
create table if not exists dmt.fact_metric (
  id bigint,
  app_dwid bigint,
  server_dwid bigint,
  metric_index_dwid bigint,
  hour_dwid bigint,
  `timestamp` timestamp,
  value bigint
)
partitioned by (creation_date string)
stored as parquet;
