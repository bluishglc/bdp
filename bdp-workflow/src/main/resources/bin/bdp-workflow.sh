#!/bin/sh
#A shell script to manage oozie workflow for big data platform.
#Author: Laurence Geng
export BDP_WORKFLOW_LOCAL_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"
export BDP_WORKFLOW_HDFS_HOME="${app.hdfs.home}"
export BDP_WORKFLOW_DONE_FLAGS_HOME="hdfs://${app.hdfs.user.home}/done-flags"
export OOZIE_URL="${cluster.oozie.url}"

USER_NAME=${app.user.name}

source "$BDP_WORKFLOW_LOCAL_HOME/bin/util.sh"


# ---------------------------------------- Common Functions ---------------------------------------- #

showUsage()
{
    printHeading "PROJECT [ BDP-WORKFLOW ] USAGE"

    echo "# 说明：初始化工作流，将工作流配置文件部署到HDFS"
    echo "$0 init"
    echo

    echo "# 说明：提交coordinator，指定作业排期的起止时间"
    echo "$0 submit COORDINATOR_NAME START_TIME END_TIME"
    echo

    echo "# 示例：提交bdp-master在数据源层的coordinator，作业排期是从2018-09-02到2018-09-03，由于作业采集的是T-1的数据，所以这个命令处理的是2018-09-01到2018-09-02的数据"
    echo "$0 submit ds-bdp-master-daily-build '2018-09-02T00:00+0800' '2018-09-03T00:00+0800'"
    echo

    echo "# 说明：提交全部的coordinator，指定作业排期的起止时间"
    echo "$0 submit-all COORDINATOR_NAME START_TIME END_TIME"
    echo

    echo "# 示例：提交全部的coordinator，作业排期是从2018-09-02到2018-09-03，由于作业采集的是T-1的数据，所以这个命令处理的是2018-09-01到2018-09-02的数据"
    echo "$0 submit-all '2018-09-02T00:00+0800' '2018-09-03T00:00+0800'"
    echo
}

# ---------------------------------------- Major Functions ---------------------------------------- #

init()
{
    hdfs dfs -test -d ${BDP_WORKFLOW_HDFS_HOME}&&\
    hdfs dfs -rm -r -f -skipTrash ${BDP_WORKFLOW_HDFS_HOME}
    hdfs dfs -mkdir -p ${BDP_WORKFLOW_HDFS_HOME} &&\
    hdfs dfs -chown ${USER_NAME} ${BDP_WORKFLOW_HDFS_HOME}
    hdfs dfs -put ${BDP_WORKFLOW_LOCAL_HOME}/* ${BDP_WORKFLOW_HDFS_HOME}/
    # create done-flag directory.
    hdfs dfs -mkdir -p ${BDP_WORKFLOW_DONE_FLAGS_HOME}
}

submit()
{
    COORD_NAME=$1
    START_TIME=$(date -d "$2" +"%FT%H:%M%z")
    END_TIME=$(date -d "$3" +"%FT%H:%M%z")
    echo "Accepted Start Time: [ ${START_TIME} ]"
    echo "Accepted End Time: [ ${END_TIME} ]"

    OOZIE_MSG=$(oozie job -submit \
    -Doozie.coord.application.path="${BDP_WORKFLOW_HDFS_HOME}/lib/${COORD_NAME}" \
    -DstartTime="${START_TIME}" \
    -DendTime="${END_TIME}")
    if [ "$?" = "0" ]
    then
        echo "The Coordinator ID:  [ ${OOZIE_MSG/job: /} ]"
        echo "Submitting job succeeded!"
    else
        echo "${OOZIE_MSG}"
        echo "Submitting job failed!"
    fi
}

submitAll()
{
    submit "ds-bdp-master-daily-build" "$@"
    submit "ds-bdp-metric-daily-build" "$@"
    submit "sj-master-data-daily-build" "$@"
    submit "sj-infra-metric-daily-build" "$@"
}

# ---------------------------------------- Shell Scripts Entry ---------------------------------------- #

case $1 in
    (init)
        init
    ;;
    (show-time)
        showTime
    ;;
    (submit)
        shift
        submit "$@"
    ;;
    (submit-all)
        shift
        submitAll "$@"
    ;;
	(*)
		showUsage
	;;
esac