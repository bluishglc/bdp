package com.github.bdp.master.server.repository.impl;

import com.alibaba.fastjson.JSON;
import com.github.bdp.master.server.domain.MetricIndex;
import com.github.bdp.master.server.repository.MetricIndexRedisRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.connection.RedisConnection;
import org.springframework.data.redis.core.*;
import org.springframework.stereotype.Repository;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.List;

import static com.github.bdp.master.server.Constants.*;

@Repository
public class MetricIndexRedisRepositoryImpl implements MetricIndexRedisRepository {

    public static Logger logger = LoggerFactory.getLogger(MetricIndexRedisRepositoryImpl.class);

    private StringRedisTemplate stringRedisTemplate;

    private ValueOperations<String, String> valueOperations;

    @Autowired
    public MetricIndexRedisRepositoryImpl(StringRedisTemplate stringRedisTemplate) {
        this.stringRedisTemplate = stringRedisTemplate;
    }

    @PostConstruct
    private void init() {
        valueOperations = stringRedisTemplate.opsForValue();
    }

    private String buildRecKey(Long id) {
        return new StringBuilder(METRIC_INDEX_KEYSPACE).append(":").append(id).toString();
    }

    private String buildRecKey(MetricIndex metricIndex) {
        return buildRecKey(metricIndex.getId());
    }

    private String buildMetricNameIdxKey(MetricIndex metricIndex) {
        return buildMetricNameIdxKey(metricIndex.getName());
    }

    private String buildMetricNameIdxKey(String metricName) {
        return new StringBuilder(INDEX_PREFIX).append(METRIC_INDEX_KEYSPACE).append(":").append(metricName).toString();
    }

    @Override
    public void save(MetricIndex metricIndex) {
        String recKey = buildRecKey(metricIndex);
        String hostnameIdxKey = buildMetricNameIdxKey(metricIndex);
        valueOperations.set(recKey, JSON.toJSONString(metricIndex));
        valueOperations.set(hostnameIdxKey, recKey);
    }

    @Override
    public MetricIndex findOne(Long id) {
        return JSON.parseObject(valueOperations.get(buildRecKey(id)), MetricIndex.class);
    }

    @Override
    public MetricIndex findOne(String metricName) {
        String recKey = valueOperations.get(buildMetricNameIdxKey(metricName));
        return JSON.parseObject(valueOperations.get(recKey), MetricIndex.class);
    }

    @Override
    public List<MetricIndex> findAll() {
        return stringRedisTemplate.execute(new RedisCallback<List<MetricIndex>>(){
            @Override
            public List<MetricIndex> doInRedis(RedisConnection redisConnection) throws DataAccessException {
                List<MetricIndex> metricIndices = new ArrayList<>();
                Cursor<byte[]> cursor = redisConnection.scan(
                        new ScanOptions.ScanOptionsBuilder().match(METRIC_INDEX_KEY_PATTERN).count(Integer.MAX_VALUE).build()
                );
                while (cursor.hasNext()) {
                    MetricIndex metricIndex = JSON.parseObject(new String(redisConnection.get(cursor.next())), MetricIndex.class);
                    metricIndices.add(metricIndex);
                }
                return metricIndices;
            }
        });
    }

    @Override
    public void delete(MetricIndex metricIndex) {
        String recKey = buildRecKey(metricIndex);
        String hostnameIdxKey = buildMetricNameIdxKey(metricIndex);
        stringRedisTemplate.delete(recKey);
        stringRedisTemplate.delete(hostnameIdxKey);
    }
}
