package com.github.bdp.master.client.util

import com.github.bdp.master.client.Constants._
import com.typesafe.scalalogging.LazyLogging
import redis.clients.jedis.{Jedis, JedisPool, JedisPoolConfig}

object RedisClient extends LazyLogging {

	private val pool = new JedisPool(new JedisPoolConfig(), REDIS_HOST, REDIS_PORT)

	private def withClient[T](f: Jedis => T): T = {
		val jedis = pool.getResource
		try {
			f(jedis)
		} catch {
			case e: Throwable =>
				logger.error(s"Redis operation failed! the error message is: ${e.getMessage}")
				throw e
		}
		finally {
			jedis.close()
		}
	}

	def get(key: String): String = {
		withClient {
			jedis =>
				jedis.get(key)
		}
	}

}
