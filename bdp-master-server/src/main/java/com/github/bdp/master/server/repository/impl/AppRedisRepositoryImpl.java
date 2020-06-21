package com.github.bdp.master.server.repository.impl;

import com.alibaba.fastjson.JSON;
import com.github.bdp.master.server.domain.App;
import com.github.bdp.master.server.repository.AppRedisRepository;
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
public class AppRedisRepositoryImpl implements AppRedisRepository {

    public static Logger logger = LoggerFactory.getLogger(AppRedisRepositoryImpl.class);

    private StringRedisTemplate stringRedisTemplate;

    private ValueOperations<String, String> valueOperations;

    @Autowired
    public AppRedisRepositoryImpl(StringRedisTemplate stringRedisTemplate) {
        this.stringRedisTemplate = stringRedisTemplate;
    }

    @PostConstruct
    private void init() {
        valueOperations = stringRedisTemplate.opsForValue();
    }

    private String buildRecKey(Long id) {
        return new StringBuilder(APP_KEYSPACE).append(":").append(id).toString();
    }

    private String buildRecKey(App app) {
        return buildRecKey(app.getId());
    }

    private String buildAppNameIdxKey(App app) {
        return buildAppNameIdxKey(app.getName());
    }

    private String buildAppNameIdxKey(String appName) {
        return new StringBuilder(INDEX_PREFIX).append(APP_KEYSPACE).append(":").append(appName).toString();
    }

    @Override
    public void save(App app) {
        String recKey = buildRecKey(app);
        String hostnameIdxKey = buildAppNameIdxKey(app);
        valueOperations.set(recKey, JSON.toJSONString(app));
        valueOperations.set(hostnameIdxKey, recKey);
    }

    @Override
    public App findOne(Long id) {
        return JSON.parseObject(valueOperations.get(buildRecKey(id)),App.class);
    }

    @Override
    public App findOne(String appName) {
        String recKey = valueOperations.get(buildAppNameIdxKey(appName));
        return JSON.parseObject(valueOperations.get(recKey), App.class);
    }

    @Override
    public List<App> findAll() {
        return stringRedisTemplate.execute(new RedisCallback<List<App>>(){
            @Override
            public List<App> doInRedis(RedisConnection redisConnection) throws DataAccessException {
                List<App> apps = new ArrayList<>();
                Cursor<byte[]> cursor = redisConnection.scan(
                        new ScanOptions.ScanOptionsBuilder().match(APP_KEY_PATTERN).count(Integer.MAX_VALUE).build()
                );
                while (cursor.hasNext()) {
                    App app = JSON.parseObject(new String(redisConnection.get(cursor.next())), App.class);
                    apps.add(app);
                }
                return apps;
            }
        });
    }

    @Override
    public void delete(App app) {
        String recKey = buildRecKey(app);
        String hostnameIdxKey = buildAppNameIdxKey(app);
        stringRedisTemplate.delete(recKey);
        stringRedisTemplate.delete(hostnameIdxKey);
    }
}
