#!/usr/bin/env bash

export BDP_IMPORT_HOME="$(cd "`dirname $(readlink -nf "$0")`"/..; pwd -P)"

source "$BDP_IMPORT_HOME/bin/util.sh"

# ------------------------------------------------   Common Methods   ------------------------------------------------ #

showUsage()
{
    showLocalUsage
    $BDP_IMPORT_HOME/bin/bdp-master-import.sh help
    $BDP_IMPORT_HOME/bin/bdp-metric-import.sh help
}

showLocalUsage()
{
    printHeading "PROJECT [ BDP-IMPORT ] USAGE"

    echo "# 说明：创建所有表在tmp层上的schema，并从数据源导入指定时间范围内的所有表的数据到tmp的对应表"
    echo "$0 init-all"
    echo

    echo "# 示例：创建所有表在tmp层上的schema，并从数据源导入2018-09-01的所有表的数据到tmp的对应表"
    echo "$0 init-all '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo

    echo "# 说明：创建所有表在tmp层上的schema"
    echo "$0 create-all"
    echo

    echo "# 说明：从数据源导入指定时间范围内的所有表的数据到tmp的对应表"
    echo "$0 import-all START_TIME END_TIME"
    echo

    echo "# 示例：从数据源导入2018-09-01的所有表的数据到tmp的对应表"
    echo "$0 import-all '2018-09-01T00:00+0800' '2018-09-02T00:00+0800'"
    echo
}

initAll()
{
    $BDP_IMPORT_HOME/bin/bdp-master-import.sh init-all "$@"
    $BDP_IMPORT_HOME/bin/bdp-metric-import.sh init-all "$@"
}

createAll()
{
    $BDP_IMPORT_HOME/bin/bdp-master-import.sh create-all "$@"
    $BDP_IMPORT_HOME/bin/bdp-metric-import.sh create-all "$@"
}

importAll()
{
    $BDP_IMPORT_HOME/bin/bdp-master-import.sh import-all "$@"
    $BDP_IMPORT_HOME/bin/bdp-metric-import.sh import-all "$@"
}

# ----------------------------------------------    Scripts Entrance    ---------------------------------------------- #

case $1 in
    (init-all)
        shift
        initAll "$@"
    ;;
    (create-all)
        createAll
    ;;
    (import-all)
        shift
        importAll "$@"
    ;;
    (help)
        showUsage
    ;;
    (*)
        showUsage
    ;;
esac
