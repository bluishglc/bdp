-- noinspection sqlnodatasourceinspectionforfile

drop table if exists dmt.dim_hour;
create table if not exists dmt.dim_hour (
  dwid bigint,
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
  weekend_flag boolean
)
stored as parquet;

-- staging tables

drop table if exists tmp.dim_hour;
create table if not exists tmp.dim_hour (
  dwid bigint,
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
  weekend_flag boolean
)
row format delimited
fields terminated by ','
stored as textfile
location '/data/tmp/dim_hour/';