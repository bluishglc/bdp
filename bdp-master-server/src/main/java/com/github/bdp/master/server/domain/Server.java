package com.github.bdp.master.server.domain;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.Map;
import java.util.Set;


@Entity
@Table(name = "server")
public class Server implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "hostname", nullable = false)
    private String hostname;

    @Column(name = "cpu_cores", nullable = false)
    private Integer cpuCores;

    @Column(name = "memory", nullable = false)
    private Integer memory;

    @Column(name = "app_id", nullable = false)
    private Long appId;

    @ElementCollection
    @CollectionTable(
        name = "metric_threshold",
        joinColumns = @JoinColumn(name = "server_id", foreignKey = @ForeignKey(name = "fk_metric_threshold_server"))
    )
    @MapKeyColumn(name = "metric_name")
    private Map<String, MetricThreshold> metricThresholds;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name="creation_time", insertable = false, updatable = false, columnDefinition="TIMESTAMP default CURRENT_TIMESTAMP")
    private Date creationTime;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name="update_time", insertable = false, columnDefinition="TIMESTAMP default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP")
    private Date updateTime;


    /*--------------------------------------------    Getters/Setters    ---------------------------------------------*/

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getHostname() {
        return hostname;
    }

    public void setHostname(String hostname) {
        this.hostname = hostname;
    }

    public Integer getCpuCores() {
        return cpuCores;
    }

    public void setCpuCores(Integer cpuCores) {
        this.cpuCores = cpuCores;
    }

    public Integer getMemory() {
        return memory;
    }

    public void setMemory(Integer memory) {
        this.memory = memory;
    }

    public Long getAppId() {
        return appId;
    }

    public void setAppId(Long appId) {
        this.appId = appId;
    }

    public Map<String, MetricThreshold> getMetricThresholds() {
        return metricThresholds;
    }

    public void setMetricThresholds(Map<String, MetricThreshold> metricThresholds) {
        this.metricThresholds = metricThresholds;
    }

    public Date getCreationTime() {
        return creationTime;
    }

    public void setCreationTime(Date creationTime) {
        this.creationTime = creationTime;
    }

    public Date getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }
}
