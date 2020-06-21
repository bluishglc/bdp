package com.github.bdp.master.server;

public interface Constants {
    String APP_KEYSPACE = "bdp-metric";
    String APP_KEY_PATTERN = "bdp-metric:*";
    String SERVER_KEYSPACE = "server";
    String SERVER_KEY_PATTERN = "server:*";
    String METRIC_INDEX_KEYSPACE = "metric_index";
    String METRIC_INDEX_KEY_PATTERN = "metric_index:*";
    String ALERT_INDEX_KEYSPACE = "alert_index";
    String ALERT_INDEX_KEY_PATTERN = "alert_index:*";
    String INDEX_PREFIX = "i_";
    String JOIN_PREFIX = "x_";
}
