package com.github.bdp.master.server.repository.impl;

import com.alibaba.fastjson.JSON;
import com.github.bdp.master.server.domain.Server;
import com.github.bdp.master.server.repository.ServerRedisRepository;
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
public class ServerRedisRepositoryImpl implements ServerRedisRepository {

    public static Logger logger = LoggerFactory.getLogger(ServerRedisRepositoryImpl.class);

    private StringRedisTemplate stringRedisTemplate;

    private ValueOperations<String, String> valueOperations;

    private SetOperations<String, String> setOperations;

    @Autowired
    public ServerRedisRepositoryImpl(StringRedisTemplate stringRedisTemplate) {
        this.stringRedisTemplate = stringRedisTemplate;
    }

    @PostConstruct
    private void init() {
        valueOperations = stringRedisTemplate.opsForValue();
        setOperations = stringRedisTemplate.opsForSet();
    }

    private String buildRecKey(Long id) {
        return new StringBuilder(SERVER_KEYSPACE).append(":").append(id).toString();
    }

    private String buildRecKey(Server server) {
        return buildRecKey(server.getId());
    }

    private String buildHostnameIdxKey(Server server) {
        return buildHostnameIdxKey(server.getHostname());
    }

    private String buildHostnameIdxKey(String serverName) {
        return new StringBuilder(INDEX_PREFIX).append(SERVER_KEYSPACE).append(":").append(serverName).toString();
    }

    private String buildAppServerJoinKey(Server server) {
        return new StringBuilder(JOIN_PREFIX).append(APP_KEYSPACE).append(":")
                .append(server.getAppId()).append(":").append(SERVER_KEYSPACE).toString();
    }

    @Override
    public void save(Server server) {
        String recKey = buildRecKey(server);
        String hostnameIdxKey = buildHostnameIdxKey(server);
        String appServerJoinKey = buildAppServerJoinKey(server);
        valueOperations.set(recKey, JSON.toJSONString(server));
        valueOperations.set(hostnameIdxKey, recKey);
        setOperations.add(appServerJoinKey, server.getId().toString());
    }

    @Override
    public Server findOne(Long id) {
        return JSON.parseObject(valueOperations.get(buildRecKey(id)),Server.class);
    }

    @Override
    public Server findOne(String serverName) {
        String recKey = valueOperations.get(buildHostnameIdxKey(serverName));
        return JSON.parseObject(valueOperations.get(recKey), Server.class);
    }

    @Override
    public List<Server> findAll() {
        return stringRedisTemplate.execute(new RedisCallback<List<Server>>(){
            @Override
            public List<Server> doInRedis(RedisConnection redisConnection) throws DataAccessException {
                List<Server> servers = new ArrayList<>();
                Cursor<byte[]> cursor = redisConnection.scan(
                        new ScanOptions.ScanOptionsBuilder().match(SERVER_KEY_PATTERN).count(Integer.MAX_VALUE).build()
                );
                while (cursor.hasNext()) {
                    Server server = JSON.parseObject(new String(redisConnection.get(cursor.next())), Server.class);
                    servers.add(server);
                }
                return servers;
            }
        });
    }

    @Override
    public void delete(Server server) {
        String recKey = buildRecKey(server);
        String hostnameIdxKey = buildHostnameIdxKey(server);
        String appServerJoinKey = buildAppServerJoinKey(server);
        stringRedisTemplate.delete(recKey);
        stringRedisTemplate.delete(hostnameIdxKey);
        setOperations.remove(appServerJoinKey, server.getId().toString());
    }
}
