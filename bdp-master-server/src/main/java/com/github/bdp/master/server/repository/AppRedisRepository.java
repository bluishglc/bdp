package com.github.bdp.master.server.repository;

import com.github.bdp.master.server.domain.App;

import java.util.List;

public interface AppRedisRepository {
    void save(App app);
    App findOne(Long id);
    App findOne(String name);
    List<App> findAll();
    void delete(App app);
}
