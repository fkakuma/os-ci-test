#!/bin/bash
set -xe

export BASE=/opt/stack
BASEDIR=$BASE/new
export SCRIPTS_DIR=.tox/dsvm-fullstack/bin
GATE_HOOK_LOG=$BASEDIR/gate_hook.sh.log

cd $BASEDIR
date
bash -xe $BASEDIR/neutron/neutron/tests/contrib/gate_hook.sh dsvm-fullstack 1>$GATE_HOOK_LOG
GATE_HOOK_RET=`echo $?`
if [ $GATE_HOOK_RET -ne 0 ]; then
    cat $GATE_HOOK_LOG
    exit $GATE_HOOK_RET
fi
date
bash -xe $BASEDIR/neutron/neutron/tests/contrib/post_test_hook.sh dsvm-fullstack
date
