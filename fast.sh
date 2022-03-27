#!/bin/bash

###################################
#                                 #
#  INSTALLS OS TOOLS              #
#                                 #
###################################
install_OS() {
    sudo rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc
    sudo -E apt-get -qq update
    sudo -E apt-get -qq upgrade -y
    sudo -E apt-get -qq install p7zip-full build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python
    sudo -E apt-get -qq autoremove --purge
    sudo -E apt-get -qq clean
}

###################################
#                                 #
#  DOWNLOADS OPENWRT              #
#                                 #
###################################
dl_ow(){
    if [ "$RELEASE" = "snapshots" ]; then
        MANIFEST="https://downloads.openwrt.org/snapshots/targets/$TARGET/$ARCH/openwrt-$TARGET-$ARCH.manifest"
        IMAGEBUILDER="https://downloads.openwrt.org/snapshots/targets/$TARGET/$ARCH/openwrt-imagebuilder-$TARGET-$ARCH.Linux-x86_64.tar.xz"
    else
        MANIFEST="https://downloads.openwrt.org/releases/$RELEASE/targets/$TARGET/$ARCH/openwrt-$RELEASE-$TARGET-$ARCH.manifest"
        IMAGEBUILDER="https://downloads.openwrt.org/releases/$RELEASE/targets/$TARGET/$ARCH/openwrt-imagebuilder-$RELEASE-$TARGET-$ARCH.Linux-x86_64.tar.xz"
    fi	
    STD_PACKAGES=$( wget $MANIFEST -O - | awk '{print $1}' | sort | tr '\n' ' ' )
    rm -rf $DIR
    mkdir -p $DIR
    cd $DIR
    wget $IMAGEBUILDER -O - | tar xJf - --strip-components=1;
   mkdir -p packages
   cp -r ../files files
 }

###################################
#                                 #
#  BUILD IMAGE                    #
#                                 #
###################################
makeall(){
    ## BUILD THE FIRMWARE
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    make -j16 image PROFILE=$PROFILE PACKAGES="$DIFF_PACKAGES" FILES=./files/ EXTRA_IMAGE_NAME="$(date +"%Y.%m.%d-%H%M")"
    manifest=$( find "$PWD/bin" -name "*manifest" )
    FINAL_PACKAGES=$( cat $manifest | awk '{print $1}' | sort | tr '\n' ' ' )
    echo -e $( wc -w <<< $DIFF_PACKAGES ) " CUSTOM PACKAGES:  \n$DIFF_PACKAGES \n"
    echo -e $( wc -w <<< $STD_PACKAGES ) " STANDARD MANIFEST: \n$STD_PACKAGES \n"
    echo -e $( wc -w <<< $FINAL_PACKAGES ) " FINAL MANIFEST:  \n$FINAL_PACKAGES \n"
    echo -e "OUTPUT FOLDER:\n" `dirname $manifest` "\n"
    echo -e "OUTPUT FILES:"
    ls -als $( dirname $manifest )
}

###################################
#                                 #
#  CLEAN AFTER BUILD              #
#                                 #
###################################
cleanIBkitchen(){ 
    rm -rf bin tmp build_dir
}

###################################
#                                 #
#  ADDS ARGON THEME               #
#                                 #
###################################
add_argon(){
    # THEME-ARGON
    DIFF_PACKAGES+=" luci-lib-ipkg luci-theme-argon luci-app-argon-config -luci-theme-bootstrap"
    URL=$(wget -q https://api.github.com/repos/jerrykuku/luci-theme-argon/releases/latest -O - | awk -F \" -v RS="," '/browser_download_url/ && /argon_/ {print $(NF-1)}')
    wget $URL -O packages/$(basename "$URL")
    URL=$(wget -q https://api.github.com/repos/jerrykuku/luci-theme-argon/releases/latest -O - | awk -F \" -v RS="," '/browser_download_url/ && /config_/ {print $(NF-1)}')
    wget $URL -O packages/$(basename "$URL")
}

###################################
#                                 #
#  DEVICE SETUP                   #
#                                 #
###################################

set_R6020() {
    DIR=R6020
    PROFILE="netgear_r6020"
    RELEASE="21.02.2"         # or "snapshots", "21.02.2", "21.02.1", or any previous release.
    TARGET="ramips"
    ARCH="mt76x8"
    DIFF_PACKAGES="luci nano-plus htop iperf3 wpad-mesh-wolfssl -wpad-basic-wolfssl luci-app-vnstat2 luci-app-nlbwmon"
    dl_ow $DIR $REPO $BRANCH
    #add_argon
}

set_E8450() {
    DIR=E8450
    PROFILE=linksys_e8450-ubi
    RELEASE=snapshots
    TARGET=mediatek
    ARCH=mt7622
    DIFF_CONFIG=E8450.config
    DIFF_PACKAGES="mc nano-plus htop ncdu iperf3 irqbalance auc ca-certificates ca-buldle -wpad-basic-wolfssl -libustream-wolfssl -px5g-wolfssl wpad-openssl libustream-openssl luci-ssl-openssl luci luci-compat luci-mod-dashboard luci-app-attendedsysupgrade luci-app-vnstat2 luci-app-nlbwmon luci-app-adblock luci-app-banip luci-app-bcp38 luci-app-commands luci-app-ddns ddns-scripts-noip luci-app-openvpn luci-ssl-openssl luci-app-sqm luci-app-wireguard luci-app-upnp luci-app-uhttpd luci-app-statistics collectd-mod-conntrack collectd-mod-cpu collectd-mod-cpufreq collectd-mod-dhcpleases collectd-mod-entropy collectd-mod-exec collectd-mod-interface collectd-mod-iwinfo collectd-mod-load collectd-mod-memory collectd-mod-network collectd-mod-ping collectd-mod-rrdtool collectd-mod-sqm collectd-mod-thermal collectd-mod-uptime collectd-mod-wireless blockd cryptsetup e2fsprogs f2fs-tools kmod-fs-exfat kmod-fs-ext4 kmod-fs-f2fs kmod-fs-hfs kmod-fs-hfsplus kmod-fs-msdos kmod-fs-nfs kmod-fs-nfs-common kmod-fs-nfs-v3 kmod-fs-nfs-v4 kmod-fs-vfat kmod-nls-base kmod-nls-cp1250 kmod-nls-cp437 kmod-nls-cp850 kmod-nls-iso8859-1 kmod-nls-iso8859-15 kmod-nls-utf8 kmod-usb-storage kmod-usb-storage-uas libblkid ntfs-3g nfs-utils ip6tables-mod-nat 6in4 6rd 6to4 ip6tables-nft luci-app-ttyd"
    REPO=
    BRANCH=
    dl_ow $DIR $REPO $BRANCH
    set_packages "$DIFF_PACKAGES"
    add_argon
    add_nano-full
}

set_R7800() {
    DIR=R7800
    PROFILE="netgear_r7800"
    RELEASE="snapshots"
    TARGET="ipq806x"
    ARCH="generic"
    DIFF_CONFIG="R7800.config"
    DIFF_PACKAGES="mc nano-plus htop ncdu iperf3 irqbalance auc ca-certificates -wpad-basic-wolfssl -libustream-wolfssl -px5g-wolfssl wpad-openssl libustream-openssl luci-ssl-openssl luci luci-compat luci-mod-dashboard luci-app-attendedsysupgrade luci-app-vnstat2 luci-app-nlbwmon luci-app-adblock luci-app-banip luci-app-bcp38 luci-app-commands luci-app-ddns ddns-scripts-noip luci-app-openvpn -luci-ssl-openssl luci-app-sqm luci-app-wireguard luci-app-upnp luci-app-uhttpd luci-app-statistics collectd-mod-conntrack collectd-mod-cpu collectd-mod-cpufreq collectd-mod-dhcpleases collectd-mod-entropy collectd-mod-exec collectd-mod-interface collectd-mod-iwinfo collectd-mod-load collectd-mod-memory collectd-mod-network collectd-mod-ping collectd-mod-rrdtool collectd-mod-sqm collectd-mod-thermal collectd-mod-uptime collectd-mod-wireless blockd cryptsetup e2fsprogs f2fs-tools kmod-fs-exfat kmod-fs-ext4 kmod-fs-f2fs kmod-fs-hfs kmod-fs-hfsplus kmod-fs-msdos kmod-fs-nfs kmod-fs-nfs-common kmod-fs-nfs-v3 kmod-fs-nfs-v4 kmod-fs-vfat kmod-nls-base kmod-nls-cp1250 kmod-nls-cp437 kmod-nls-cp850 kmod-nls-iso8859-1 kmod-nls-iso8859-15 kmod-nls-utf8 kmod-usb-storage kmod-usb-storage-uas libblkid ntfs-3g nfs-utils ip6tables-mod-nat 6in4 6rd 6to4 ip6tables-nft luci-theme-argon luci-app-argon-config luci-lib-ipkg luci-app-ttyd"
    dl_ow $DIR $REPO $BRANCH
    set_packages "$DIFF_PACKAGES"
    add_argon
    add_nano-full
}

set_R7800NSS() {
    DIR=R7800NSS
    PROFILE="netgear_r7800"
    RELEASE="snapshots"
    TARGET="ipq806x"
    ARCH="generic"
    DIFF_PACKAGES="nano-plus htop ncdu iperf3 irqbalance auc luci luci-compat luci-mod-dashboard luci-app-attendedsysupgrade luci-theme-argon luci-app-argon-config luci-lib-ipkg luci-app-ttyd luci-app-vnstat2 luci-app-nlbwmon"
    REPO="https://github.com/ACwifidude/openwrt"
    BRANCH="kernel5.10-nss-qsdk11.0"
    DIFF_CONFIG="R7800NSS-ACwifidude.config"
    dl_ow $DIR $REPO $BRANCH
    set_packages "$DIFF_PACKAGES"
    add_argon
    add_nano-full
}

###################################
#                                 #
#  COMPLETE DEVICE                # 
#  SETUP AND BUILD                #
#                                 #
###################################

build(){
    set_$1
    makeall
}

echo "$@"
instruction=$1
shift
$instruction $@
if [ -n "$GITHUB_ACTIONS" ]; then
    echo "EXPORTING CONFIGURATION TO GITHUN ACTION $GITHUB_RUN_NUMBER"
    echo "PROFILE=$PROFILE" >>$GITHUB_ENV
    echo "TARGET=$TARGET" >>$GITHUB_ENV
    echo "ARCH=$ARCH" >>$GITHUB_ENV
    echo "RELEASE=$RELEASE" >>$GITHUB_ENV
    echo "DIFF_PACKAGES=$DIFF_PACKAGES" >>$GITHUB_ENV
    echo "LAST_PWD=$PWD" >>$GITHUB_ENV
    echo "PROFILE=$PROFILE"
    echo "TARGET=$TARGET"
    echo "ARCH=$ARCH"
    echo "RELEASE=$RELEASE"
    echo "DIFF_PACKAGES=$DIFF_PACKAGES"
    echo "LAST_PWD=$PWD"
fi
