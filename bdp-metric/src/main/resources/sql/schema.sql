drop database if exists bdp_metric;
create database if not exists bdp_metric;

drop user if exists 'bdp_metric'@'node1.cluster';
create user if not exists 'bdp_metric'@'node1.cluster' identified by 'Bdpp1234!';
grant all privileges on bdp_metric.* to 'bdp_metric'@'node1.cluster' with grant option;
flush privileges;

use bdp_metric;

drop table if exists metric;

create table if not exists metric (
  `id` bigint(20) not null auto_increment,
  `name` varchar(255) not null,
  `hostname` varchar(255) not null,
  `value` bigint(20) not null,
  `timestamp` datetime not null,
  primary key (`id`)
) engine=innodb auto_increment=1 default charset=utf8;

drop table if exists alert;

create table if not exists alert (
  `id` bigint(20) not null auto_increment,
  `message` varchar(255) not null,
  `hostname` varchar(255) not null,
  `status` varchar(6) not null,
  `timestamp` datetime not null,
  `created_time` timestamp not null default current_timestamp,
  primary key (`id`)
) engine=innodb auto_increment=1 default charset=utf8;