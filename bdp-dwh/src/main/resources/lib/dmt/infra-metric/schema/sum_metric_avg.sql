-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dmt.sum_metric_avg;
create table if not exists dmt.sum_metric_avg (
  app_dwid bigint,
  server_dwid bigint,
  metric_index_dwid bigint,
  metric_threshold_dwid bigint,
  hour_dwid bigint,
  avg_value int,
  rag string
)
partitioned by (creation_date string)
stored as parquet;
