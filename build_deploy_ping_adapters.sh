#!/usr/bin/env bash

##==========================================================
## Env settings
##==========================================================
#remote.key=YOUR_KEY.pem
##==========================================================
## DevOps settings properties
##==========================================================
#devops.local.adapter.bin=BIN_LOCATION_OF_ADAPTERS
#devops.local.resources=RESOURCE_LOCATION
#devops.local.ext=*jar
#devops.remote.host=USER@HOST
#devops.remote.dir=/home/USER
#devops.remote.script.file=REMOTE_DEPLOY
#devops.remote.script.user=REMOTE_USER_WITH_EXEC_RIGHTS


command -v ccze >/dev/null 2>&1 || { echo >&2 "Need ccze installed, can find.  Aborting."; exit 1; }
# set java version
export JAVA_HOME=$(/usr/libexec/java_home -v 11.0.2)

ENV=${1:-dev}

function prop {
    grep -w "${1}" ${ENV}.env|cut -d'=' -f2
}


buildAll ()
{
for i in $(ls plugin-src/);
    do
        echo ${i%%/};
        ant -Dtarget-plugin.name=${i%%/} "$1"-plugin | ccze -A
    done
}

upload ()
{
    scp -3 -i $(prop 'remote.key') $(prop 'devops.local.adapter.bin')/$(prop 'devops.local.ext')  $(prop 'devops.remote.host'):$(prop 'devops.remote.dir')
}

sync ()
{
    # sync adapter targets
    rsync -Pav -e ssh $(pwd)/$(prop 'devops.local.adapter.bin') $(prop 'devops.remote.host'):$(prop 'devops.remote.dir')
    # sync resources
    rsync -Pav -e ssh $(pwd)/$(prop 'devops.local.resources') $(prop 'devops.remote.host'):$(prop 'devops.remote.dir')
}

COMMAND='sudo bash '$(prop 'devops.remote.dir')/$(prop 'devops.local.resources')/$(prop 'devops.remote.script.file')
CMD=uptime
execRemote()
{
    ssh  $(prop 'devops.remote.host') ${COMMAND}
}

clean_and_build ()
{
    echo "cleaning"
    buildAll "clean"
    echo "cleaning"
    buildAll "$1"
}


if [[ "$2" == "upload" ]];
    then
        upload
elif [[ "$2" == "deploy" ]];
    then
        clean_and_build "deploy"
elif [[ "$2" == "build" ]];
    then
        clean_and_build "build"
elif [[ "$2" == "remote" ]];
    then
#        clean_and_build "build"
        sync
        execRemote
else
    echo "Don't know what to do, printing settings"
    echo "Remote Key "  $(prop 'remote.key')
    echo "File local dir " $(prop 'devops.local.dir')
    echo "File extension" $(prop 'devops.local.ext')
    echo "Remote host" $(prop 'devops.remote.host')
    echo "Remote dir" $(prop 'devops.remote.dir')

fi
