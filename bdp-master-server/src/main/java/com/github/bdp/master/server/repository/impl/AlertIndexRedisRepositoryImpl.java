package com.github.bdp.master.server.repository.impl;

import com.alibaba.fastjson.JSON;
import com.github.bdp.master.server.domain.AlertIndex;
import com.github.bdp.master.server.repository.AlertIndexRedisRepository;
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
public class AlertIndexRedisRepositoryImpl implements AlertIndexRedisRepository {

    public static Logger logger = LoggerFactory.getLogger(AlertIndexRedisRepositoryImpl.class);

    private StringRedisTemplate stringRedisTemplate;

    private ValueOperations<String, String> valueOperations;

    @Autowired
    public AlertIndexRedisRepositoryImpl(StringRedisTemplate stringRedisTemplate) {
        this.stringRedisTemplate = stringRedisTemplate;
    }

    @PostConstruct
    private void init() {
        valueOperations = stringRedisTemplate.opsForValue();
    }

    private String buildRecKey(Long id) {
        return new StringBuilder(ALERT_INDEX_KEYSPACE).append(":").append(id).toString();
    }

    private String buildRecKey(AlertIndex alertIndex) {
        return buildRecKey(alertIndex.getId());
    }

    private String buildAlertNameIdxKey(AlertIndex alertIndex) {
        return buildAlertNameIdxKey(alertIndex.getName());
    }

    private String buildAlertNameIdxKey(String alertName) {
        return new StringBuilder(INDEX_PREFIX).append(ALERT_INDEX_KEYSPACE).append(":").append(alertName).toString();
    }

    @Override
    public void save(AlertIndex alertIndex) {
        String recKey = buildRecKey(alertIndex);
        String hostnameIdxKey = buildAlertNameIdxKey(alertIndex);
        valueOperations.set(recKey, JSON.toJSONString(alertIndex));
        valueOperations.set(hostnameIdxKey, recKey);
    }

    @Override
    public AlertIndex findOne(Long id) {
        return JSON.parseObject(valueOperations.get(buildRecKey(id)), AlertIndex.class);
    }

    @Override
    public AlertIndex findOne(String alertName) {
        String recKey = valueOperations.get(buildAlertNameIdxKey(alertName));
        return JSON.parseObject(valueOperations.get(recKey), AlertIndex.class);
    }

    @Override
    public List<AlertIndex> findAll() {
        return stringRedisTemplate.execute(new RedisCallback<List<AlertIndex>>(){
            @Override
            public List<AlertIndex> doInRedis(RedisConnection redisConnection) throws DataAccessException {
                List<AlertIndex> alertIndices = new ArrayList<>();
                Cursor<byte[]> cursor = redisConnection.scan(
                        new ScanOptions.ScanOptionsBuilder().match(ALERT_INDEX_KEY_PATTERN).count(Integer.MAX_VALUE).build()
                );
                while (cursor.hasNext()) {
                    AlertIndex alertIndex = JSON.parseObject(new String(redisConnection.get(cursor.next())), AlertIndex.class);
                    alertIndices.add(alertIndex);
                }
                return alertIndices;
            }
        });
    }

    @Override
    public void delete(AlertIndex alertIndex) {
        String recKey = buildRecKey(alertIndex);
        String hostnameIdxKey = buildAlertNameIdxKey(alertIndex);
        stringRedisTemplate.delete(recKey);
        stringRedisTemplate.delete(hostnameIdxKey);
    }
}
