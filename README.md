# 大数据平台工程原型（Big Data Platform Project Prototype）


2008年Hadoop成为Apache的顶级项目，以此为开端，大数据技术迎来了十多年的持续发展，其间随着Spark的异军突起，整个大数据生态圈又经历了一次“装备升级”，变得更加完善和强大。今天，很多企业已经完成了早期对大数据技术的尝试和探索转而进入到应用阶段，但不得不说的是，大数据平台的架构体系非常庞大，技术堆栈特别深，从事大数据开发的同学对此应该都深有体会。

而在很多细分领域（例如实时计算、作业调度）也没有像样的工程模板, 这一现状与Java社区使用Spring Boot信手拈来地搭建Web工程原型形成了鲜明了对比。这导致很多团队在启动大数据平台建设时往往感到无所侍从，也使得希望深入学习大数据技术的开发者由于缺少工程级的示例参考而感到迷茫。

该原型项目就是以此为命题创建的，它基于过往项目的最佳实践提炼而来，可以帮助团队快速启动开发，上手就写业务代码。

本项目同时是《[大数据平台架构与原型实现：数据中台建设实战](https://item.jd.com/12677623.html)》一书的配套示例代码。该书已由知名IT图书品牌电子工业出版社博文视点出版发行，在京东和当当有售。
关于如何部署和运行该项目，书中做了非常细致的讲解。

京东购书链接：[https://item.jd.com/12677623.html](https://item.jd.com/12677623.html)

当当购书链接：[http://product.dangdang.com/28974965.html](http://product.dangdang.com/28974965.html)


点击[《重磅推荐：建大数据平台太难了！给我发个工程原型吧！》](https://laurence.blog.csdn.net/article/details/106851739)了解图书详情，扫码进入京东手机购书页面！

![大数据平台架构与原型实现：数据中台建设实战](https://user-images.githubusercontent.com/5539582/87127144-03b62700-c2c0-11ea-96d1-5f1a29da8ab0.jpg)


---


## 部署原型项目使用到的脚本

《[大数据平台架构与原型实现：数据中台建设实战](https://item.jd.com/12677623.html)》一书的第《4.5 部署原型项目》节详细介绍了该项目的部署和启动方法，为了免于手写代码，便于大家操作，我们将使用的相关脚本和配置粘贴出来：

- 4.5.1.1 在远程服务器上建立应用程序专有账号

```bash
# Run as 'root'
# add group if not exists
group=bdp

egrep "^$group\:" /etc/group >& /dev/null
if [ "$?" != "0" ]
then
    groupadd "$group"
    echo "Group: $group is added."
fi
    
users=(bdp-metric bdp-collect bdp-dwh bdp-master-server bdp-stream bdp-workflow)
password='Bdpp1234!'
for user in ${users[@]}
do
    # add user if not exists and set password
    egrep "^$user\:" /etc/passwd >& /dev/null
    if [ "$?" != "0" ]
    then
        useradd -g "$group" "$user"
        echo "User: $user is added."
        echo "$user:$password"|chpasswd
        echo "User: $user, password is reset."
    fi
done

# enable all users of bdp group can sudo as hdfs. 
echo '%bdp ALL = (hdfs) NOPASSWD: ALL'>/etc/sudoers.d/bdp
```

- 4.5.1.2 在HDFS上为程序专有账号创建Home目录

```bash
# create home on hdfs for users need hdfs storage
su -l hdfs
users=(bdp-dwh bdp-stream bdp-workflow)
for user in ${users[@]}
do
    home=/user/$user
    hdfs dfs -test -d $home && hdfs dfs -rm -r -f $home
    hdfs dfs -mkdir -p $home
    hdfs dfs -chown -R $user:bdp $home
done
exit
```


- 4.5.1.3 在HDFS上创建数据仓库所需文件夹

```bash
# create data zones
su -l hdfs
dirs=(/data/src /data/dwh /data/dmt /data/app /data/tmp /data/stg)

for dir in ${dirs[@]}
do
    hdfs dfs -test -d $dir && hdfs dfs -rm -r -f $dir
    hdfs dfs -mkdir -p $dir
    hdfs dfs -chown -R bdp-dwh:bdp $dir
done

hdfs dfs -chmod a+w /data/tmp

exit
```

- 4.5.1.4 创建数据仓库

```sql
drop database if exists src cascade;
create database if not exists src
location '/data/src';

drop database if exists dwh cascade;
create database if not exists dwh
location '/data/dwh';

drop database if exists dmt cascade;
create database if not exists dmt
location '/data/dmt';

drop database if exists app cascade;
create database if not exists app
location '/data/app';

drop database if exists tmp cascade;
create database if not exists tmp
location '/data/tmp';

drop database if exists stg cascade;
create database if not exists stg
location '/data/stg';
```

- 4.5.1.5 创建bdp-stream的日志目录

```bash
mkdir /var/log/bdp-stream
chown bdp-stream:bdp /var/log/bdp-stream
chmod a+w /var/log/bdp-stream
```

- 4.5.1.9 创建`bdp_metric`和`bdp_master`数据库

```sql
-- 1. bdp_metric
DROP DATABASE IF EXISTS bdp_metric;
CREATE DATABASE IF NOT EXISTS bdp_metric DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'bdp_metric'@'%';
CREATE USER IF NOT EXISTS 'bdp_metric'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON bdp_metric.* TO 'bdp_metric'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 2. bdp_master

DROP DATABASE IF EXISTS bdp_master;
CREATE DATABASE IF NOT EXISTS bdp_master DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'bdp_master'@'%';
CREATE USER IF NOT EXISTS 'bdp_master'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON bdp_master.* TO 'bdp_master'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

- 4.5.1.10 创建kafka topic

```bash
kafka-topics \
    --zookeeper master1.cluster:2181,master1.cluster:2181,utility1.cluster:2181 \
    --create \
    --topic cpu.usage \
    --partitions 12 \
    --replication-factor 3

kafka-topics \
    --zookeeper master1.cluster:2181,master1.cluster:2181,utility1.cluster:2181 \
    --describe \
    --topic cpu.usage

kafka-topics \
    --zookeeper master1.cluster:2181,master1.cluster:2181,utility1.cluster:2181 \
    --create \
    --topic mem.used \
    --partitions 12 \
    --replication-factor 3

kafka-topics \
    --zookeeper master1.cluster:2181,master1.cluster:2181,utility1.cluster:2181 \
    --describe \
    --topic mem.used

kafka-topics \
    --zookeeper master1.cluster:2181,master1.cluster:2181,utility1.cluster:2181 \
    --create \
    --topic alert \
    --partitions 12 \
    --replication-factor 3

kafka-topics \
    --zookeeper master1.cluster:2181,master1.cluster:2181,utility1.cluster:2181 \
    --describe \
    --topic alert
```

- 4.5.1.11 创建HBase数据表

```
disable 'metric'
drop 'metric'
create 'metric', {NAME=>'f', VERSIONS=>1, COMPRESSION => 'SNAPPY', BLOCKCACHE => 'true'}

disable 'alert'
drop 'alert'
create 'alert', {NAME=>'f', VERSIONS=>1, COMPRESSION => 'SNAPPY', BLOCKCACHE => 'true'}

disable 'server_state'
drop 'server_state'
create 'server_state', {NAME=>'f', VERSIONS=>1, COMPRESSION => 'SNAPPY', BLOCKCACHE => 'true'}
```



## 安装集群过程中使用到的脚本

《[大数据平台架构与原型实现：数据中台建设实战](https://item.jd.com/12677623.html)》一书的第三章介绍了一个7节点CDH集群的安装过程，为了免于手写代码，便于大家操作，我们将使用的相关脚本和配置粘贴出来：

- 3.3.4.1 生成yum repo文件

```bash
tee /etc/yum.repos.d/galera.repo <<EOF
[galera]
name = Galera
baseurl = https://releases.galeracluster.com/galera-3/centos/7/x86_64
gpgkey = https://releases.galeracluster.com/GPG-KEY-galeracluster.com
gpgcheck = 1

[mysql-wsrep]
name = MySQL-wsrep
baseurl =  http://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64
gpgkey = http://releases.galeracluster.com/mysql-wsrep-5.7/GPG-KEY-galeracluster.com
gpgcheck = 1
EOF
```

- 3.3.4.4 配置Galera集群

```bash
[root@master1 ~]# tee /etc/my.cnf <<EOF
!includedir /etc/my.cnf.d/
[mysqld]
max_connections=1000
max_connect_errors=10000
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
binlog_format=ROW
bind-address=0.0.0.0
default_storage_engine=innodb
innodb_autoinc_lock_mode=2
innodb_flush_log_at_trx_commit=0
innodb_buffer_pool_size=122M
character-set-server=utf8
collation-server=utf8_general_ci
character_set_server=utf8
collation_server=utf8_general_ci
wsrep_provider=/usr/lib64/galera-3/libgalera_smm.so
wsrep_provider_options="gcache.size=300M; gcache.page_size=300M"
wsrep_cluster_name="mysql_cluster"
wsrep_cluster_address="gcomm://master1.cluster,master2.cluster,utility1.cluster"
wsrep_node_name="master1.cluster"
wsrep_node_address="10.0.0.86"
wsrep_sst_method=rsync

[mysql_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
EOF
```


- 3.3.5.1 下载CDH Repository

```bash
nohup wget --recursive --no-parent --no-host-directories https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/5.15.2/ -P /opt/nginx/cloudera-repos &

nohup wget --recursive --no-parent --no-host-directories https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/RPM-GPG-KEY-cloudera -P /opt/nginx/cloudera-repos &

nohup wget --recursive --no-parent --no-host-directories https://archive.cloudera.com/cdh5/parcels/5.15.2/ -P /opt/nginx/cloudera-repos &
```

- 3.3.5.2 安装并配置Nginx

```conf
server {
    listen       80 default_server;
    listen       [::]:80 default_server;
    server_name  _;
    root         /opt/nginx;

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;

    location / {
        autoindex on;
    }
}
```

- 3.3.5.3 生成Repository描述文件

```bash
tee /etc/yum.repos.d/cloudera-manager.repo <<EOF
[cloudera-manager]
name=Cloudera Manager 5.15.2
baseurl=http://utility1.cluster/cloudera-repos/cm5/redhat/7/x86_64/cm/5.15.2/
gpgkey=http://utility1.cluster/cloudera-repos/cm5/redhat/7/x86_64/cm/RPM-GPG-KEY-cloudera
gpgcheck=1
EOF
```

- 3.3.6.3 创建CDH各服务使用的数据库

```sql
-- 1. scm
DROP DATABASE IF EXISTS scm;
CREATE DATABASE IF NOT EXISTS scm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'scm'@'%';
CREATE USER IF NOT EXISTS 'scm'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON scm.* TO 'scm'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 2. amon

DROP DATABASE IF EXISTS amon;
CREATE DATABASE IF NOT EXISTS amon DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'amon'@'%';
CREATE USER IF NOT EXISTS 'amon'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON amon.* TO 'amon'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 3. rman

DROP DATABASE IF EXISTS rman;
CREATE DATABASE IF NOT EXISTS rman DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'rman'@'%';
CREATE USER IF NOT EXISTS 'rman'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON rman.* TO 'rman'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 4. hue

DROP DATABASE IF EXISTS hue;
CREATE DATABASE IF NOT EXISTS hue DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'hue'@'%';
CREATE USER IF NOT EXISTS 'hue'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON hue.* TO 'hue'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 5. hive

DROP DATABASE IF EXISTS hive;
CREATE DATABASE IF NOT EXISTS hive DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'hive'@'%';
CREATE USER IF NOT EXISTS 'hive'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON hive.* TO 'hive'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 6. sentry

DROP DATABASE IF EXISTS sentry;
CREATE DATABASE IF NOT EXISTS sentry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'sentry'@'%';
CREATE USER IF NOT EXISTS 'sentry'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON sentry.* TO 'sentry'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 7. nav

DROP DATABASE IF EXISTS nav;
CREATE DATABASE IF NOT EXISTS nav DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'nav'@'%';
CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 8. navms

DROP DATABASE IF EXISTS navms;
CREATE DATABASE IF NOT EXISTS navms DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'navms'@'%';
CREATE USER IF NOT EXISTS 'navms'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON navms.* TO 'navms'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 9. oozie

DROP DATABASE IF EXISTS oozie;
CREATE DATABASE IF NOT EXISTS oozie DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

DROP USER IF EXISTS 'oozie'@'%';
CREATE USER IF NOT EXISTS 'oozie'@'%' IDENTIFIED BY 'Bdpp1234!';
GRANT ALL PRIVILEGES ON oozie.* TO 'oozie'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```


- 3.3.6.4. 安装MySQL JDBC Driver

```bash
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.48.tar.gz
tar zxvf mysql-connector-java-5.1.48.tar.gz
mkdir -p /usr/share/java/
cp mysql-connector-java-5.1.48/mysql-connector-java-5.1.48-bin.jar /usr/share/java/mysql-connector-java.jar
```

- 3.3.10 启用Spark SQL

```bash
cp hive-cli-1.2.1.spark2.jar /opt/cloudera/parcels/SPARK2/lib/spark2/jars/
cp spark-hive-thriftserver_2.11-2.3.0.jar /opt/cloudera/parcels/SPARK2/lib/spark2/jars/
cp stop-thriftserver.sh /opt/cloudera/parcels/SPARK2/lib/spark2/sbin/
cp start-thriftserver.sh /opt/cloudera/parcels/SPARK2/lib/spark2/sbin/
cp spark-sql /opt/cloudera/parcels/SPARK2/lib/spark2/bin/
```

```bash
alternatives --install /usr/bin/spark-shell spark-shell /opt/cloudera/parcels/SPARK2/bin/spark2-shell 1
alternatives --install /usr/bin/spark-sql spark-sql /opt/cloudera/parcels/SPARK2/bin/spark2-sql 1
alternatives --install /usr/bin/spark-submit spark-submit /opt/cloudera/parcels/SPARK2/bin/spark2-submit 1
alternatives --install /etc/spark/conf spark-conf /etc/spark2/conf.cloudera.spark2_on_yarn 1
alternatives --remove spark-shell /opt/cloudera/parcels/CDH-5.15.2-1.cdh5.15.2.p0.3/bin/spark-shell
alternatives --remove spark-submit /opt/cloudera/parcels/CDH-5.15.2-1.cdh5.15.2.p0.3/bin/spark-submit
```
