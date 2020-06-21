package com.github.bdp.master.client.domain

import java.sql.Timestamp

case class MetricThreshold(amberThreshold: Int, redThreshold: Int, creationTime: Timestamp, updateTime: Timestamp)
