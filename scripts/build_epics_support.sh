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
export SUPPORT_PATH=${WS_PATH}/support
export THIRD_PARTY_PKGS_PATH=${WS_PATH}/3rdPartyPkgs
export ASYN_BRANCH=R4-44
export SEQUENCER_BRANCH=R2-2-9
export CALC_BRANCH=R3-7-5
export IPAC_BRANCH=2.16
export STREAMDEVICE_BRANCH=2.8.25
export SSCAN_BRANCH=R2-11-6
export MODBUS_BRANCH=master
# OPCUA
export OPEN62541_BRANCH=1.3
export EPICS_OPCUA_BRANCH=master
export EPICS_SUPPORT_EXPORTS_FILE=~/.bashrc

setup() {
    git config --global http.postBuffer 524288000
    git config --global core.compression 0
    mkdir -p ${SUPPORT_PATH}
    mkdir -p ${THIRD_PARTY_PKGS_PATH}
    touch ${EPICS_SUPPORT_EXPORTS_FILE}
    chmod +x ${EPICS_SUPPORT_EXPORTS_FILE}
}

build_asyn() {
    cd "${SUPPORT_PATH}" || { echo "Unable to cd to $SUPPORT_PATH"; exit 56; }

    # Pull asyn
    git clone -b ${ASYN_BRANCH} https://github.com/epics-modules/asyn.git asyn --depth=1
    ln -sf asyn asyn-${ASYN_BRANCH}

    # Build asyn
    cd ${SUPPORT_PATH}/asyn &&
    git stash &&
    sed -e "s/# TIRPC=YES.*/TIRPC=YES/g" -i configure/CONFIG_SITE &&
    sed -e '/EPICS_BASE/ s/^#*/#/' -i configure/RELEASE &&
    echo "EPICS_BASE=${WS_PATH}/epics-base" >> configure/RELEASE &&
    echo "SUPPORT=${SUPPORT_PATH}" >> configure/RELEASE &&
    echo "SSCAN=${SUPPORT_PATH}/sscan" >> configure/RELEASE &&
    echo "SNCSEQ=${SUPPORT_PATH}/sequencer" >> configure/RELEASE &&
    echo "CALC=${SUPPORT_PATH}/calc" >> configure/RELEASE &&
    echo "IPAC=${SUPPORT_PATH}/ipac" >> configure/RELEASE &&
    make clean &&
    make &&
    echo "export LD_LIBRARY_PATH=${SUPPORT_PATH}/asyn-${ASYN_BRANCH}/lib/$EPICS_HOST_ARCH:$LD_LIBRARY_PATH" >> $EPICS_SUPPORT_EXPORTS_FILE && source $EPICS_SUPPORT_EXPORTS_FILE
}

build_modbus() {
    cd "${SUPPORT_PATH}" || { echo "Unable to cd to $SUPPORT_PATH"; exit 56; }

    # Pull modbus
    git clone -b ${MODBUS_BRANCH} https://github.com/epics-modules/modbus.git modbus --depth=1
    ln -sf modbus modbus-${MODBUS_BRANCH}

    # Build Modbus
    cd ${SUPPORT_PATH}/modbus &&
    git stash &&
    echo "SUPPORT=${WS_PATH}/support" >> configure/RELEASE &&
    echo "ASYN=${SUPPORT_PATH}/asyn" >> configure/RELEASE &&
    echo "EPICS_BASE=${WS_PATH}/epics-base" >> configure/RELEASE &&
    make clean &&
    make &&
    echo "export LD_LIBRARY_PATH=${SUPPORT_PATH}/modbus-${MODBUS_BRANCH}/lib/$EPICS_HOST_ARCH:$LD_LIBRARY_PATH" >> $EPICS_SUPPORT_EXPORTS_FILE && source $EPICS_SUPPORT_EXPORTS_FILE
}

build_opcua() {
    mkdir -p ${THIRD_PARTY_PKGS_PATH}
    cd "${THIRD_PARTY_PKGS_PATH}" || { echo "Unable to cd to $THIRD_PARTY_PKGS_PATH"; exit 56; }

    # Pull open62541
    cd ${THIRD_PARTY_PKGS_PATH}
    git clone -b ${OPEN62541_BRANCH} --recursive https://github.com/open62541/open62541.git --depth=1
    ln -sf open62541 open62541-${OPEN62541_BRANCH}

    # Build open62541
    cd ${THIRD_PARTY_PKGS_PATH}/open62541 && rm -rf open62541_install && mkdir -p open62541_install && mkdir -p build && cd build &&
    cmake .. -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DUA_ENABLE_ENCRYPTION=OPENSSL \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
        -DCMAKE_INSTALL_PREFIX=${PWD}/../open62541_install &&
        make && make install
    cd ${PWD}/../open62541_install
    ln -sf lib64 lib

    # Pull EPICS opcua
    cd "${SUPPORT_PATH}" || { echo "Unable to cd to $SUPPORT_PATH"; exit 56; }
    git clone -b ${EPICS_OPCUA_BRANCH} https://github.com/epics-modules/opcua.git --depth=1
    ln -sf opcua opcua-${EPICS_OPCUA_BRANCH}

    # Build EPICS opcua
    cd ${SUPPORT_PATH}/opcua &&
    git stash &&
    rm -f ${SUPPORT_PATH}/opcua/configure/CONFIG_SITE.local &&
    sed -e '/EPICS_BASE/ s/^#*/#/' -i configure/RELEASE &&
    sed -e "/^#EPICS_BASE.*/i EPICS_BASE=$WS_PATH/epics-base" -i configure/RELEASE &&
    sed -e "/^RULES.*/a EPICS_BASE=$WS_PATH/epics-base" -i configure/CONFIG &&
    sed -e '/EPICS_BASE/ s/^#*/#/' -i exampleTop/configure/RELEASE &&
    sed -e "/^#EPICS_BASE.*/i EPICS_BASE=$WS_PATH/epics-base" -i exampleTop/configure/RELEASE &&
    touch ${SUPPORT_PATH}/opcua/configure/CONFIG_SITE.local &&
    echo "OPEN62541=${THIRD_PARTY_PKGS_PATH}/open62541/open62541_install" >> configure/CONFIG_SITE.local &&
    echo "OPEN62541_SHRLIB_DIR=${THIRD_PARTY_PKGS_PATH}/open62541/open62541_install/bin" >> configure/CONFIG_SITE.local &&
    echo "OPEN62541_LIB=${THIRD_PARTY_PKGS_PATH}/open62541/open62541_install/lib64" >> configure/CONFIG_SITE.local &&
    echo "OPEN62541_DEPLOY_MODE = EMBED" >> configure/CONFIG_SITE.local &&
    echo "OPEN62541_USE_CRYPTO = YES" >> configure/CONFIG_SITE.local &&
    echo "USR_CXXFLAGS_Linux += -std=c++11" >> configure/CONFIG_SITE.local &&
    make clean &&
    make &&
    sed -e "/export LD_LIBRARY_PATH/d" -i $EPICS_SUPPORT_EXPORTS_FILE && # Delete all the LD_LIBRARY_PATH in ~/.bashrc file and set the final lib paths
    echo "export LD_LIBRARY_PATH=${SUPPORT_PATH}/opcua-${EPICS_OPCUA_BRANCH}/lib/$EPICS_HOST_ARCH:$LD_LIBRARY_PATH" >> $EPICS_SUPPORT_EXPORTS_FILE && source $EPICS_SUPPORT_EXPORTS_FILE
}

build_deps() {
    cd "${SUPPORT_PATH}" || { echo "Unable to cd to $SUPPORT_PATH"; exit 56; }
    # Pull sequencer
    git clone -b ${SEQUENCER_BRANCH} https://github.com/epics-modules/sequencer.git --depth=1
    ln -sf sequencer sequencer-${SEQUENCER_BRANCH}
    cd ${SUPPORT_PATH}/sequencer &&
    git stash &&
    echo "EPICS_BASE=${WS_PATH}/epics-base" >> configure/RELEASE &&
    make clean &&
    make &&
    echo "export LD_LIBRARY_PATH=${SUPPORT_PATH}/sequencer-${SEQUENCER_BRANCH}/lib/$EPICS_HOST_ARCH:$LD_LIBRARY_PATH" >> $EPICS_SUPPORT_EXPORTS_FILE && source $EPICS_SUPPORT_EXPORTS_FILE

    # Pull ipac
    cd "${SUPPORT_PATH}" || { echo "Unable to cd to $SUPPORT_PATH"; exit 56; }
    git clone -b ${IPAC_BRANCH} https://github.com/epics-modules/ipac --depth=1
    ln -sf ipac ipac-${IPAC_BRANCH}
    cd ${SUPPORT_PATH}/ipac &&
    git stash &&
    echo "EPICS_BASE=${WS_PATH}/epics-base" >> configure/RELEASE &&
    make clean &&
    make &&
    echo "export LD_LIBRARY_PATH=${SUPPORT_PATH}/ipac-${IPAC_BRANCH}/lib/$EPICS_HOST_ARCH:$LD_LIBRARY_PATH" >> $EPICS_SUPPORT_EXPORTS_FILE && source $EPICS_SUPPORT_EXPORTS_FILE

    # Pull sscan
    cd "${SUPPORT_PATH}" || { echo "Unable to cd to $SUPPORT_PATH"; exit 56; }
    git clone -b ${SSCAN_BRANCH} https://github.com/epics-modules/sscan.git --depth=1
    ln -sf sscan sscan-${SSCAN_BRANCH}
    cd ${SUPPORT_PATH}/sscan &&
    git stash &&
    sed -e '/SUPPORT/ s/^#*/#/' -i configure/RELEASE &&
    echo "EPICS_BASE=${WS_PATH}/epics-base" >> configure/RELEASE &&
    echo "SUPPORT=${SUPPORT_PATH}" >> configure/RELEASE &&
    echo "SNCSEQ=${SUPPORT_PATH}/sequencer" >> configure/RELEASE &&
    make clean &&
    make &&
    echo "export LD_LIBRARY_PATH=${SUPPORT_PATH}/sscan-${SSCAN_BRANCH}/lib/$EPICS_HOST_ARCH:$LD_LIBRARY_PATH" >> $EPICS_SUPPORT_EXPORTS_FILE && source $EPICS_SUPPORT_EXPORTS_FILE

    # Pull calc
    cd "${SUPPORT_PATH}" || { echo "Unable to cd to $SUPPORT_PATH"; exit 56; }
    git clone -b ${CALC_BRANCH} https://github.com/epics-modules/calc.git --depth=1
    ln -sf calc calc-${CALC_BRANCH}
    cd ${SUPPORT_PATH}/calc &&
    git stash &&
    sed -e '/EPICS_BASE/ s/^#*/#/' -i configure/RELEASE &&
    sed -e '/SUPPORT/ s/^#*/#/' -i configure/RELEASE &&
    sed -e '/SSCAN/ s/^#*/#/' -i configure/RELEASE &&
    sed -e '/SNCSEQ/ s/^#*/#/' -i configure/RELEASE &&
    echo "EPICS_BASE=${WS_PATH}/epics-base" >> configure/RELEASE &&
    echo "SUPPORT=${SUPPORT_PATH}" >> configure/RELEASE &&
    echo "SSCAN=${SUPPORT_PATH}/sscan" >> configure/RELEASE &&
    echo "SNCSEQ=${SUPPORT_PATH}/sequencer" >> configure/RELEASE &&
    make clean &&
    make &&
    echo "export LD_LIBRARY_PATH=${SUPPORT_PATH}/calc-${CALC_BRANCH}/lib/$EPICS_HOST_ARCH:$LD_LIBRARY_PATH" >> $EPICS_SUPPORT_EXPORTS_FILE && source $EPICS_SUPPORT_EXPORTS_FILE
}

build_stream() {
    # Pull stream
    cd "${SUPPORT_PATH}" || { echo "Unable to cd to $SUPPORT_PATH"; exit 56; }
    git clone -b ${STREAMDEVICE_BRANCH} https://github.com/paulscherrerinstitute/StreamDevice.git stream --depth=1
    ln -sf stream stream-${STREAMDEVICE_BRANCH}
    cd ${SUPPORT_PATH}/stream &&
    git stash &&
    sed -e '/EPICS_BASE/ s/^#*/#/' -i configure/RELEASE &&
    sed -e '/ASYN/ s/^#*/#/' -i configure/RELEASE &&
    sed -e '/CALC/ s/^#*/#/' -i configure/RELEASE &&
    sed -e '/PCRE/ s/^#*/#/' -i configure/RELEASE &&
    echo "EPICS_BASE=${WS_PATH}/epics-base" >> configure/RELEASE &&
    echo "ASYN=${SUPPORT_PATH}/asyn" >> configure/RELEASE &&
    echo "CALC=${SUPPORT_PATH}/calc" >> configure/RELEASE &&
    echo "PCRE_INCLUDE=/usr/include/pcre" >> configure/RELEASE &&
    echo "PCRE_LIB=/usr/lib" >> configure/RELEASE &&
    echo "PROD_LIBS += stream \
        PROD_LIBS += asyn \
        PROD_LIBS += pcre" >> Makefile &&
    make clean &&
    make &&
    echo "export LD_LIBRARY_PATH=${SUPPORT_PATH}/stream-${STREAMDEVICE_BRANCH}/lib/$EPICS_HOST_ARCH:$LD_LIBRARY_PATH" >> $EPICS_SUPPORT_EXPORTS_FILE && source $EPICS_SUPPORT_EXPORTS_FILE
}

setup
build_deps
build_asyn
build_modbus
build_stream
build_opcua
