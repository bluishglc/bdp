package com.github.bdp.master.client.domain

import java.sql.Timestamp

case class MetricIndex(id: Long, name: String, description: String, category: String, creationTime: Timestamp, updateTime: Timestamp)
