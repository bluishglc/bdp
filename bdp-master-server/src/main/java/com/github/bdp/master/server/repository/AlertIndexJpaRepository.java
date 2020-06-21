package com.github.bdp.master.server.repository;

import com.github.bdp.master.server.domain.AlertIndex;
import org.springframework.data.repository.PagingAndSortingRepository;

public interface AlertIndexJpaRepository extends PagingAndSortingRepository<AlertIndex, Long> {}
