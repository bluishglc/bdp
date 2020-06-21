package com.github.bdp.master.server.repository;

import com.github.bdp.master.server.domain.MetricIndex;
import org.springframework.data.repository.PagingAndSortingRepository;

public interface MetricIndexJpaRepository extends PagingAndSortingRepository<MetricIndex, Long> {}
