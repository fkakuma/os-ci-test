#!/bin/bash
#set -xe

if [ -z $USER ]; then
    USER=travis
fi
DIR_PATH=`dirname $0`
pushd $DIR_PATH
SCRIPT_PATH=`pwd`
popd
export STACK_USER=stack
SUDO_EXEC="sudo -H -u $STACK_USER"
export BASE=/opt/stack
BASEDIR=$BASE/new
cat tests/ryu_info
sudo mkdir -p $BASEDIR
sudo chown -R $USER:root $BASE

sudo apt-get update
sudo apt-get install -qy patch

pushd $BASEDIR
sudo pip install -U tox
git clone https://github.com/osrg/ryu
pushd ryu
RYU_COMMIT_ID=`git log --oneline -1 | awk '{print $1}'`
RYU_COMMIT_LOG=`git log -1 --pretty=oneline`
popd
git clone https://git.openstack.org/openstack-dev/devstack
git clone https://git.openstack.org/openstack/neutron
sudo pip install -e ryu

if [ -e $SCRIPT_PATH/patch_list ]; then
    pushd neutron
    for p in `cat $SCRIPT_PATH/patch_list`; do
        patch -p1 < $SCRIPT_PATH/$p
    done
    popd
fi

sudo $BASEDIR/devstack/tools/create-stack-user.sh
#sudo chown -R $STACK_USER:$STACK_USER /opt/stack
popd

sudo chown -R $STACK_USER:$STACK_USER $BASE
$SUDO_EXEC bash -xe $DIR_PATH/fullstack_run.sh
RUN_STATUS=$?

if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
set +x
echo "machine github.com" > ~/.netrc
echo "login $GUSER" >> ~/.netrc
echo "password $GTOKEN" >> ~/.netrc
set -x
git config --global user.email 'travis@travis-ci.org'
git config --global user.name 'travis'
pushd /tmp
git clone https://github.com/fkakuma/os-ci-test
cd os-ci-test
LOG_PATH=logs/`date +%Y%m%d%H%M`-${RYU_COMMIT_ID}
git checkout debug-logs
mkdir -p $LOG_PATH
tar czf $LOG_PATH/fullstack_logs.tar.gz /opt/stack/logs
git add $LOG_PATH
git commit -a -m "build No.: $TRAVIS_BUILD_NUMBER ryu: $RYU_COMMIT_LOG"
git push origin debug-logs
popd
rm -v ~/.netrc
fi
exit $RUN_STATUS
