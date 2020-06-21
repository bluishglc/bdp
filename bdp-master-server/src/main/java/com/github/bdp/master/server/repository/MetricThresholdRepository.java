package com.github.bdp.master.server.repository;

import com.github.bdp.master.server.domain.MetricThreshold;
import org.springframework.data.repository.PagingAndSortingRepository;

public interface MetricThresholdRepository extends PagingAndSortingRepository<MetricThreshold, Long> {}
