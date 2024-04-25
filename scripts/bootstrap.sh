#! /usr/bin/env sh

# Do argument checks
if [ ! "$#" -ge 1 ]; then
    echo "Usage: $0 {distro}"
    echo "Example: $0 'rhel'"
    echo "(Default platform 'rhel')"
    exit 1
fi

# DISTRO
if [ ! -z "$1" ]; then
    DISTRO=$1
else
     DISTRO="rhel"
fi

rhel_install() {
    xfs_growfs /dev/vda3
    dnf update -y
    dnf install -y dnf-plugins-core yum-utils bash-completion tree
    dnf install epel-release -y
    dnf config-manager --set-enabled powertools
    dnf -y install gcc gcc-c++ gcc-toolset-9-make readline-devel perl-ExtUtils-Install make git cmake
    dnf -y install python3.11 python3.11-pip gstreamer1 libnotify-devel
    dnf -y install pcre # Package required by the StreamDevice
    dnf -y install re2c # Packages required by the sequencer
    dnf -y install rpcgen libtirpc-devel # Packages required by epics-modules/asyn
    # Packages required by the Canberra and Amptek support in epics-modules/mca
    dnf -y install libnet-devel libpcap-devel libusb-devel
    # Packages required by the Linux drivers in epics-modules/measComp
    dnf -y install libnet-devel libpcap-devel libusb-devel
    # Packages required by areaDetector/ADSupport/GraphicsMagick
    dnf -y install xorg-x11-proto-devel libX11-devel libXext-devel
    # Packages required by areaDetector/ADEiger
    dnf -y install zeromq-devel
    # Packages required to build aravis 7.0.2 for areaDetector/ADAravis
    dnf -y install ninja-build meson glib2-devel libxml2-devel gtk3-devel
    dnf -y gstreamer1 gstreamer1-devel gstreamer1-plugins-base-devel
    dnf -y libnotify-devel gtk-doc gobject-introspection-devel
    # Packages required to build areaDetector/ADVimba
    dnf -y install glibmm24-devel
    # Packages required to build EDM
    dnf -y install giflib giflib-devel zlib-devel libpng-devel motif-devel libXtst-devel
    # Packages required to build MEDM
    dnf -y install libXt-devel motif-devel
    # Packages required to build open62541
    dnf -y install octave mbedtls-devel openssl-devel crypto-devel
    systemctl stop firewalld
    systemctl disable firewalld
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
}

if [ "$DISTRO" == "rhel" ]; then
    rhel_install
else
    echo "NOT IMPLEMENTED YET!!!"
fi
