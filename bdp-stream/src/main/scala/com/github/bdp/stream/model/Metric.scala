package com.github.bdp.stream.model

import java.sql.Timestamp

case class Metric(id: Long, name: String, hostname: String, value: Long, timestamp: Timestamp)