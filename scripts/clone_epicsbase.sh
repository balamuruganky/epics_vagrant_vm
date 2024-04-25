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
export EPICS_BRANCH=R7.0.6

clone_epics() {
    cd "$WS_PATH" || { echo "Unable to cd to $WS_PATH"; exit 56; } &&
    git clone -b ${EPICS_BRANCH}  --recursive https://github.com/epics-base/epics-base.git epics-base --depth=1
    # Build the EPICS-base
    ln -sf epics-base epics-base-${EPICS_BRANCH}
}

clone_epics
