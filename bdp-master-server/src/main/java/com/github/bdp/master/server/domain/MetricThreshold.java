package com.github.bdp.master.server.domain;

import javax.persistence.*;
import java.util.Date;

@Embeddable
//@Table(name="metric_threshold")
public class MetricThreshold {

    private static final long serialVersionUID = 1L;

    @Column(name = "red_threshold")
    private Integer redThreshold;

    @Column(name = "amber_threshold")
    private Integer amberThreshold;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name="creation_time", insertable = false, updatable = false, columnDefinition="TIMESTAMP default CURRENT_TIMESTAMP")
    private Date creationTime;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name="update_time", insertable = false, columnDefinition="TIMESTAMP default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP")
    private Date updateTime;


    /*--------------------------------------------    Getters/Setters    ---------------------------------------------*/

    public Integer getRedThreshold() {
        return redThreshold;
    }

    public void setRedThreshold(Integer redThreshold) {
        this.redThreshold = redThreshold;
    }

    public Integer getAmberThreshold() {
        return amberThreshold;
    }

    public void setAmberThreshold(Integer amberThreshold) {
        this.amberThreshold = amberThreshold;
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
