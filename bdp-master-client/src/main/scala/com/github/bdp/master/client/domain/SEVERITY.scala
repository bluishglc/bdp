package com.github.bdp.master.client.domain

object SEVERITY extends Enumeration {
  type SEVERITY = Value
  val GREEN = Value(0, "GREEN")
  val AMBER = Value(1, "AMBER")
  val RED = Value(2, "RED")
}
