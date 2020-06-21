set foreign_key_checks=0;

alter table bdp_master.app disable keys;
truncate bdp_master.app;
insert into bdp_master.app (id, name, description, version, creation_time, update_time) values (1, 'MyCRM', 'The Customer Relationship Management System', '7.0', '2018-09-01 00:00:00', '2018-09-01 00:00:00');
insert into bdp_master.app (id, name, description, version, creation_time, update_time) values (2, 'MyOMS', 'The Order Management System', '2016', '2018-09-01 00:00:00', '2018-09-01 00:00:00');
alter table bdp_master.app enable keys;

alter table bdp_master.server disable keys;
truncate bdp_master.server;
insert into bdp_master.server (id, cpu_cores, hostname, memory, app_id, creation_time, update_time) values (1, 16, 'svr1001', '64000', 1, '2018-09-01 00:00:00', '2018-09-01 00:00:00');
insert into bdp_master.server (id, cpu_cores, hostname, memory, app_id, creation_time, update_time) values (2, 16, 'svr1002', '64000', 1, '2018-09-01 00:00:00', '2018-09-01 00:00:00');
alter table bdp_master.server enable keys;

alter table bdp_master.metric_threshold disable keys;
truncate bdp_master.metric_threshold;
insert into bdp_master.metric_threshold (amber_threshold, metric_name, red_threshold, server_id, creation_time, update_time) values (80, 'cpu.usage', 90, 1, '2018-09-01 00:00:00', '2018-09-01 00:00:00');
insert into bdp_master.metric_threshold (amber_threshold, metric_name, red_threshold, server_id, creation_time, update_time) values (5120, 'mem.used', 5760, 1, '2018-09-01 00:00:00', '2018-09-01 00:00:00');
insert into bdp_master.metric_threshold (amber_threshold, metric_name, red_threshold, server_id, creation_time, update_time) values (80, 'cpu.usage', 90, 2, '2018-09-01 00:00:00', '2018-09-01 00:00:00');
insert into bdp_master.metric_threshold (amber_threshold, metric_name, red_threshold, server_id, creation_time, update_time) values (5120, 'mem.used', 5760, 2, '2018-09-01 00:00:00', '2018-09-01 00:00:00');
alter table bdp_master.metric_threshold enable keys;

alter table bdp_master.metric_index disable keys;
truncate bdp_master.metric_index;
insert into bdp_master.metric_index (id, name, description, category, creation_time, update_time) values (1, 'cpu.usage', 'The instantaneous usage of cpu', 'cpu', '2018-09-01 00:00:00', '2018-09-01 00:00:00');
insert into bdp_master.metric_index (id, name, description, category, creation_time, update_time) values (2, 'mem.used', 'The instantaneous value of used memory', 'memory', '2018-09-01 00:00:00', '2018-09-01 00:00:00');
alter table bdp_master.metric_index enable keys;


alter table bdp_master.alert_index disable keys;
truncate bdp_master.alert_index;
insert into bdp_master.alert_index (id, name, severity, creation_time, update_time) values (1, 'free space warning (mb) for host disk', 2, '2018-09-01 00:00:00', '2018-09-01 00:00:00');
alter table bdp_master.alert_index enable keys;

set foreign_key_checks=1;
