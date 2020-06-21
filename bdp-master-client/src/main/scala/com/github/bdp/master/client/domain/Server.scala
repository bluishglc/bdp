package com.github.bdp.master.client.domain

import java.sql.Timestamp

case class Server(id: Long, hostname: String, cpuCores: Int,  memory: Int, appId: Long, metricThresholds: Map[String, MetricThreshold], creationTime: Timestamp, updateTime: Timestamp)
