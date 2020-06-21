package com.github.bdp.master.server.repository;

import com.github.bdp.master.server.domain.Server;

import java.util.List;

public interface ServerRedisRepository {

    void save(Server server);

    Server findOne(Long id);

    Server findOne(String name);

    List<Server> findAll();

    void delete(Server server);
}
