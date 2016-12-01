#!/bin/bash
set -xe

export BASE=/opt/stack
BASEDIR=$BASE/new
mkdir -p $BASEDIR
pushd $BASEDIR

bash -xe $BASEDIR/neutron/neutron/tests/contrib/gate_hook.sh dsvm-fullstack
bash -xe $BASEDIR/neutron/neutron/tests/contrib/post_test_hook.sh dsvm-fullstack
popd
