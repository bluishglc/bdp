update bdp_master.app set version='7.1', update_time='2018-09-02 00:00:00' where id=1;
update bdp_master.server set memory=128000, update_time='2018-09-02 00:00:00' where id=1;
update bdp_master.metric_index set description='The instantaneous usage percent of cpu', update_time='2018-09-02 00:00:00' where id=1;
update bdp_master.metric_threshold set amber_threshold=85, update_time='2018-09-02 00:00:00' where server_id=1 and metric_name='cpu.usage';