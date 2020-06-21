#!/usr/bin/env bash

export BDP_METRIC_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"

GEN_CPU_USAGE_PID="/tmp/GEN_CPU_USAGE_PID.pid"
GEN_MEM_USED_PID="/tmp/GEN_MEM_USED_PID.pid"
GEN_ALERT_PID="/tmp/GEN_ALERT_PID.pid"

MEM_USED_MAX_LANDING_SECONDS=60
ALERT_MAX_LIVE_SECONDS=60

MAX_MEM=64000

# ------------------------------------------------   Common Methods   ------------------------------------------------ #

showUsage() {
    printHeading "BDP-METRIC USAGE"
    echo "# 启动程序生成dummy的metric和alert数据，并持续运行给定的分钟数，如果没有指定时间，默认是60分钟。"
    echo "$0 start [MINUTES]"
    echo
    echo "# 终止程序"
    echo "$0 stop"
    echo
    echo "# 重启程序"
    echo "$0 restart"
    echo
    echo "# 生成指定时间区间内的dummy的cpu.usage, mem.used和alert数据"
    echo "$0 gen-offline-data COUNT START_DATE END_DATE"
    echo
    echo "# 生成dummy的cpu.usage数据，并持续运行给定的分钟数，如果没有指定时间，默认是60分钟。"
    echo "$0 gen-online-cpu-usage [MINUTES]"
    echo
    echo "# 生成指定时间区间内的dummy的cpu.usage数据"
    echo "$0 gen-offline-cpu-usage COUNT START_DATE END_DATE"
    echo
    echo "# 生成dummy的mem.used数据，并持续运行给定的分钟数，如果没有指定时间，默认是60分钟。"
    echo "$0 gen-online-mem-used [MINUTES]"
    echo
    echo "# 生成指定时间区间内的dummy的mem.used数据"
    echo "$0 gen-offline-mem-used COUNT START_DATE END_DATE"
    echo
    echo "# 生成dummy的alert数据，并持续运行给定的分钟数，如果没有指定时间，默认是60分钟。"
    echo "$0 gen-online-alert [MINUTES]"
    echo
    echo "# 生成指定时间区间内的dummy的alert数据"
    echo "$0 gen-offline-alert COUNT START_DATE END_DATE"
    echo
}

printHeading() {
    title="$1"
    paddingWidth=$((($(tput cols)-${#title})/2-3))
    printf "\n%${paddingWidth}s"|tr ' ' '='
    printf " [ $title ] "
    printf "%${paddingWidth}s\n\n"|tr ' ' '='
}

validateTime() {
    if [ "$1" = "" ]
    then
        echo "Time is missing!"
        exit 1
    fi
    TIME=$1
    date -d "$TIME" >/dev/null 2>&1
    if [ "$?" != "0" ]
    then
        echo "Invalid Time: $TIME"
        exit 1
    fi
}

# ------------------------------------------------    Major Methods   ------------------------------------------------ #

createSchema() {
    mysql -h ${db.host} -u root  -p${db.password} < $BDP_METRIC_HOME/sql/schema.sql
}

genOnlineCpuUsage() {

    minutes="${1:-60}"
    curTime=$(date +%s)
    endTime=$(date -d "+ $minutes minute" +%s)

    template="gen-cpu-usage.sql"

    while [ "$curTime" -le "$endTime" ]
    do
        value1=$(($RANDOM%100)) #random cpu value from 0 to 100
        value2=$(($RANDOM%100)) #random cpu value from 0 to 100

        sed "s/@timestamp@/$(date +'%F %T')/g" "$BDP_METRIC_HOME/sql/$template" | \
        sed "s/@value1@/$value1/g" | \
        sed "s/@value2@/$value2/g" > "$BDP_METRIC_HOME/sql/.$template"
        mysql -h ${db.host} -u root  -p${db.password} -s --prompt=nowarning < "$BDP_METRIC_HOME/sql/.$template" > /dev/null 2>&1

        printf "%s\n\n%s\n" "$(printHeading "CPU.USAGE")" "$(cat "$BDP_METRIC_HOME/sql/.$template")"
        sleep 1
        curTime=$(date +%s)
    done
}

genOnlineMemUsed() {
    minutes="${1:-60}"
    curTime=$(date +%s)
    endTime=$(date -d "+ $minutes minute" +%s)

    template="gen-mem-used.sql"

    while [ "$curTime" -le "$endTime" ]
    do
        # time shift to simulate data landing on database delay
        actualTime=$((curTime-$RANDOM%$MEM_USED_MAX_LANDING_SECONDS))
        timestamp=$(date -d @$actualTime +'%F %T')

        value1=$(($RANDOM%$MAX_MEM)) #random free mem value from 0 to 64000
        value2=$(($RANDOM%$MAX_MEM)) #random free  mem value from 0 to 64000

        sed "s/@timestamp@/$timestamp/g" "$BDP_METRIC_HOME/sql/$template" | \
        sed "s/@value1@/$value1/g" | \
        sed "s/@value2@/$value2/g" > "$BDP_METRIC_HOME/sql/.$template"

        mysql -h ${db.host} -u root  -p${db.password} -s --prompt=nowarning < "$BDP_METRIC_HOME/sql/.$template" >/dev/null 2>&1

        printf "%s\n\n%s\n" "$(printHeading "MEM.USED")" "$(cat "$BDP_METRIC_HOME/sql/.$template")"
        sleep 1
        curTime=$(date +%s)
    done
}

genOfflineCpuUsage() {

    index=1
    count="$1"

    validateTime "$2"
    validateTime "$3"

    startDate=$(date -d "$2" +"%s")
    endDate=$(date -d "$3" +"%s")

    template="gen-cpu-usage.sql"

    while [ "$index" -le "$count" ]
    do
        value1=$(($RANDOM%100)) #random cpu value from 0 to 100
        value2=$(($RANDOM%100)) #random cpu value from 0 to 100
        # NOTE: $RANDOM的范围是 [0, 32767], 不适用本例，故使用$(date +%s%N)生成随机数：
        timestamp=$(($startDate+$(date +%s%N)%($endDate-$startDate)))

        sed "s/@timestamp@/$(date -d "@$timestamp" +'%F %T')/g" "$BDP_METRIC_HOME/sql/$template" | \
        sed "s/@value1@/$value1/g" | \
        sed "s/@value2@/$value2/g" > "$BDP_METRIC_HOME/sql/.$template"
        mysql -h${db.host} -uroot -p${db.password} -s --prompt=nowarning < "$BDP_METRIC_HOME/sql/.$template" > /dev/null 2>&1

        printf "%s\n\n%s\n" "$(printHeading "CPU.USAGE")" "$(cat "$BDP_METRIC_HOME/sql/.$template")"
        index=$((index+1))
    done
}

genOfflineMemUsed() {
    index=1
    count="$1"

    validateTime "$2"
    validateTime "$3"

    startDate=$(date -d "$2" +"%s")
    endDate=$(date -d "$3" +"%s")

    template="gen-mem-used.sql"

    while [ "$index" -le "$count" ]
    do
        value1=$(($RANDOM%$MAX_MEM)) #random free mem value from 0 to 64000
        value2=$(($RANDOM%$MAX_MEM)) #random free  mem value from 0 to 64000
        # NOTE: $RANDOM的范围是 [0, 32767], 不适用本例，故使用$(date +%s%N)生成随机数：
        timestamp=$(($startDate+$(date +%s%N)%($endDate-$startDate)))
        sed "s/@timestamp@/$(date -d "@$timestamp" +'%F %T')/g" "$BDP_METRIC_HOME/sql/$template" | \
        sed "s/@value1@/$value1/g" | \
        sed "s/@value2@/$value2/g" > "$BDP_METRIC_HOME/sql/.$template"
        mysql -h${db.host} -uroot -p${db.password} -s --prompt=nowarning < "$BDP_METRIC_HOME/sql/.$template" > /dev/null 2>&1

        printf "%s\n\n%s\n" "$(printHeading "MEM.USED")" "$(cat "$BDP_METRIC_HOME/sql/.$template")"

        index=$((index+1))
    done
}

genOnlineAlert() {
    minutes="${1:-60}"
    curTime=$(date +%s)
    endTime=$(date -d "+ $minutes minute" +%s)
    template="gen-alert.sql"
    while [ "$curTime" -le "$endTime" ]
    do
        timestamp=$(date +'%F %T')

        sed "s/@timestamp@/$timestamp/g" "$BDP_METRIC_HOME/sql/$template" | \
        sed "s/@status@/OPEN/g" > "$BDP_METRIC_HOME/sql/.$template"
        mysql -h ${db.host} -u root  -p${db.password} -s --prompt=nowarning < "$BDP_METRIC_HOME/sql/.$template"  > /dev/null 2>&1
        printf "%s\n\n%s\n" "$(printHeading "OPEN ALERT")" "$(cat "$BDP_METRIC_HOME/sql/.$template")"

        # ensure alerts live time is between 5 seconds and $ALERT_MAX_LIVE_SECONDS
        sleep $(($RANDOM % ($ALERT_MAX_LIVE_SECONDS - 5) + 5))

        sed "s/@timestamp@/$timestamp/g" "$BDP_METRIC_HOME/sql/$template" | \
        sed "s/@status@/CLOSED/g" > "$BDP_METRIC_HOME/sql/.$template"
        mysql -h ${db.host} -u root  -p${db.password} -s --prompt=nowarning < "$BDP_METRIC_HOME/sql/.$template"  > /dev/null 2>&1
        printf "%s\n\n%s\n" "$(printHeading "CLOSED ALERT")" "$(cat "$BDP_METRIC_HOME/sql/.$template")"

        sleep $(($RANDOM % 5))

        curTime=$(date +%s)
    done
}

genOfflineAlert() {
    index=1
    count="$1"

    validateTime "$2"
    validateTime "$3"

    startDate=$(date -d "$2" +"%s")
    endDate=$(date -d "$3" +"%s")

    template="gen-alert.sql"

    while [ "$index" -le "$count" ]
    do
#        timestamp=$(date +'%F %T')
        # NOTE: $RANDOM的范围是 [0, 32767], 不适用本例，故使用$(date +%s%N)生成随机数：
        timestamp=$(($startDate+$(date +%s%N)%($endDate-$startDate)))
        sed "s/@timestamp@/$(date -d "@$timestamp" +'%F %T')/g" "$BDP_METRIC_HOME/sql/$template" | \
        sed "s/@status@/OPEN/g" > "$BDP_METRIC_HOME/sql/.$template"
        mysql -h ${db.host} -u root  -p${db.password} -s --prompt=nowarning < "$BDP_METRIC_HOME/sql/.$template"  > /dev/null 2>&1
        printf "%s\n\n%s\n" "$(printHeading "OPEN ALERT")" "$(cat "$BDP_METRIC_HOME/sql/.$template")"

        # ensure alerts live time is between 5 seconds and $ALERT_MAX_LIVE_SECONDS
        alertLiveSecs=$(($RANDOM % ($ALERT_MAX_LIVE_SECONDS - 5) + 5))
        timestamp=$(($timestamp + $alertLiveSecs))
        sed "s/@timestamp@/$(date -d "@$timestamp" +'%F %T')/g" "$BDP_METRIC_HOME/sql/$template" | \
        sed "s/@status@/CLOSED/g" > "$BDP_METRIC_HOME/sql/.$template"
        mysql -h ${db.host} -u root  -p${db.password} -s --prompt=nowarning < "$BDP_METRIC_HOME/sql/.$template"  > /dev/null 2>&1
        printf "%s\n\n%s\n" "$(printHeading "CLOSED ALERT")" "$(cat "$BDP_METRIC_HOME/sql/.$template")"

        index=$((index+1))
    done
}

start() {

    genOnlineCpuUsage "$@" &
    echo $! > $GEN_CPU_USAGE_PID
    genOnlineMemUsed "$@" &
    echo $! > $GEN_MEM_USED_PID
    genOnlineAlert "$@" &
    echo $! > $GEN_ALERT_PID
}

stop() {
    PIDS=($GEN_CPU_USAGE_PID $GEN_MEM_USED_PID $GEN_ALERT_PID)
    for pid in ${PIDS[@]}
    do
        if [ -f $pid ]; then
            # kill -0 == see if the PID exists
            if kill -0 `cat $pid` > /dev/null 2>&1; then
                kill `cat $pid` > /dev/null 2>&1
            fi
        fi
    done
}

# ------------------------------------------------    Major Methods   ------------------------------------------------ #

case $1 in
    (create-schema)
        createSchema
    ;;
    (start)
        shift
        start "$@"
    ;;
    (stop)
        stop
    ;;
    (restart)
        shift
        stop
        start "$@"
    ;;
    (gen-offline-data)
        shift
        genOfflineCpuUsage "$@"
        genOfflineMemUsed "$@"
        genOfflineAlert "$@"
    ;;
    (gen-online-cpu-usage)
        shift
        genOnlineCpuUsage "$@"
    ;;
    (gen-offline-cpu-usage)
        shift
        genOfflineCpuUsage "$@"
    ;;
    (gen-online-mem-used)
        shift
        genOnlineMemUsed "$@"
    ;;
    (gen-offline-mem-used)
        shift
        genOfflineMemUsed "$@"
    ;;
    (gen-online-alert)
        shift
        genOnlineAlert "$@"
    ;;
    (gen-offline-alert)
        shift
        genOfflineAlert "$@"
    ;;
    (help)
        showUsage
    ;;
    (*)
        showUsage
    ;;
esac