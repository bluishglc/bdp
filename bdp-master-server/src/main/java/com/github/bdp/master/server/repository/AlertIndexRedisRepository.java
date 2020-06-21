package com.github.bdp.master.server.repository;

import com.github.bdp.master.server.domain.AlertIndex;

import java.util.List;

public interface AlertIndexRedisRepository {
    void save(AlertIndex alertIndex);
    AlertIndex findOne(Long id);
    AlertIndex findOne(String name);
    List<AlertIndex> findAll();
    void delete(AlertIndex alertIndex);
}
