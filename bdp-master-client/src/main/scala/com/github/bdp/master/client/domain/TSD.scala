package com.github.bdp.master.client.domain

/**
 * The case class for OpenTSDB standard metrics format
 */
case class TSD(metric: String, timestamp: Long, value: String, tags: Map[String, String])