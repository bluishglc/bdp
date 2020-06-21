package com.github.bdp.stream.model

import java.sql.Timestamp

case class Alert(id: Long, message: String, hostname: String, status: String, timestamp: Timestamp)