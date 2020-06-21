package com.github.bdp.master.server.repository;

import com.github.bdp.master.server.domain.MetricIndex;

import java.util.List;

public interface MetricIndexRedisRepository {
    void save(MetricIndex metricIndex);
    MetricIndex findOne(Long id);
    MetricIndex findOne(String name);
    List<MetricIndex> findAll();
    void delete(MetricIndex metricIndex);
}
