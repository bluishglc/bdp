package com.github.bdp.master.client.domain
import java.sql.Timestamp
case class App(id: Long, name: String, description: String, version: String, creationTime: Timestamp, updateTime: Timestamp)
