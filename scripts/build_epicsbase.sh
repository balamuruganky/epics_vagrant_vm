#! /usr/bin/env sh

# Do argument checks
if [ ! "$#" -ge 1 ]; then
    echo "Usage: $0 {ws_path}"
    echo "Example: $0 '/home/vagrant/epics_ws'"
    exit 1
fi

# DISTRO
if [ ! -z "$1" ]; then
    WS_PATH=$1
else
    WS_PATH="/home/vagrant/epics_ws"
fi

echo "***** Workspace Path : $WS_PATH"

build_epicsbase() {
    cd "$WS_PATH" || { echo "Unable to cd to $WS_PATH"; exit 56; } &&
    cd ${WS_PATH}/epics-base && echo "OP_SYS_CXXFLAGS += -std=c++11" >> "configure/os/CONFIG_SITE.$(${EPICS_BASE}/startup/EpicsHostArch).Common" &&
    cd ${WS_PATH}/epics-base && make
}

build_epicsbase
