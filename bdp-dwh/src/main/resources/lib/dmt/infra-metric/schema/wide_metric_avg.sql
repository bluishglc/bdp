-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dmt.wide_metric_avg;
create table if not exists dmt.wide_metric_avg (
  app_dwid bigint,
  app_name string,
  app_description string,
  app_version string,
  server_dwid bigint,
  server_hostname string,
  server_cpu_cores int,
  server_memory int,
  metric_index_dwid bigint,
  metric_name string,
  metric_description string,
  metric_category string,
  metric_threshold_dwid bigint,
  amber_threshold int,
  red_threshold int,
  hour_dwid bigint,
  db_date string,
  db_hour timestamp,
  year int,
  month int,
  day int,
  hour int,
  quarter int,
  week int,
  day_name string,
  month_name string,
  weekend_flag boolean,
  avg_value bigint,
  rag string
)
partitioned by (creation_date string)
stored as parquet;