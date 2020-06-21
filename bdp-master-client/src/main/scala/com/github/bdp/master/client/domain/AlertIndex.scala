package com.github.bdp.master.client.domain

import java.sql.Timestamp

case class AlertIndex(id: Long, name: String, severity: Int, creationTime: Timestamp, updateTime: Timestamp)
