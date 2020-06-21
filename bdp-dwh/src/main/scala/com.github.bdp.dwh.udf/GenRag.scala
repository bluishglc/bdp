package com.github.bdp.dwh.udf
import org.apache.hadoop.hive.ql.exec.UDF

class GenRag extends UDF {
	def evaluate(avg: Int, amberThreshold: Int, redThreshold: Int): String = {
		if (avg < amberThreshold) "GREEN" else if (avg >= redThreshold) "RED" else "AMBER"
	}
}
