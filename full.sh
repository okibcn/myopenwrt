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
    sudo -E apt-get -qq install -y bzip2 diff find flex gawk gcc-6+ getopt grep libc-dev libz-dev make4.1+ perl python3.6+ rsync subversion unzip which
    sudo -E apt-get -qq autoremove --purge
    sudo -E apt-get -qq clean
}

###################################
#                                 #
#  DOWNLOADS OPENWRT              #
#                                 #
###################################
dl_ow(){
    [ -z "$1" ] && DIR=openwrt || DIR=$1
    [ -z "$2" ] && REPO=https://github.com/openwrt/openwrt || REPO=$2
    [ -z "$3" ] && BRANCH=master || BRANCH=$3
    rm -rf $DIR
    git clone --branch $BRANCH $REPO $DIR
    ls -als
    cd $DIR
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    cp ../$DIFF_CONFIG .config
    cp -r ../files files
    RELEASE=$( ./scripts/getver.sh )
}

###################################
#                                 #
#  ADD PACKAGES TO A SETUP        #
#                                 #
###################################
set_packages(){
    echo -e "\n" >>.config
    echo "# CUSTOM PACKAGE SET: $@" >>.config
    array=($(echo $@ | tr ' ' '\n'))
    for i in ${array[@]}; do
        if [ "${i:0:1}" = "-" ]; then
            sed -i "/CONFIG_PACKAGE_"${i:1}"=/d" .config
            sed -i "/CONFIG_PACKAGE_"${i:1}" /d" .config
            echo "# CONFIG_PACKAGE_${i:1} is not set" >>.config
        else
            sed -i "/CONFIG_PACKAGE_"$i"=/d" .config
            sed -i "/CONFIG_PACKAGE_"$i" /d" .config
            echo "CONFIG_PACKAGE_$i=y" >>.config
        fi
    done
}

add_argon(){
    # THEME-ARGON
    set_packages "luci-theme-argon luci-app-argon-config"
    git clone --depth 1 -b master https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
    git clone --depth 1 -b master https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
    cd package/luci-app-argon-config
    git apply ../../../argon_config.patch
    cd ../..
}

add_nano-full(){
    # NANO FULL FEATURED
    set_packages "-nano -nano-plus nano-full"
    cp ../nanorc.full files/etc/nanorc
}

###################################
#                                 #
#  BUILD IMAGE                    #
#                                 #
###################################
makeall(){
    ! [ -e diff.config ] && cp .config diff.config
    cat .config
    make defconfig && make -j$(($(nproc)*2+1)) || make -j$(($(nproc)*2+1)) || make -j1 || make -j1 V=sc
}

###################################
#                                 #
#  FAKE BUILD FULL RELEASE        #
#                                 #
###################################
fakeall() {
    mkdir -p bin/targets/family/arch/packages
    cp "../$DIFF_CONFIG" diff.config
    echo bin/targets/*/*
    cd bin/targets/*/*
    dd if=/dev/zero of=config.buildinfo bs=1K count=10
    dd if=/dev/zero of=feeds.buildinfo bs=1K count=10
    dd if=/dev/zero of=version.buildinfo bs=1K count=10
    dd if=/dev/zero of=profiles.json bs=1K count=10
    dd if=/dev/zero of=sha256sums bs=1K count=10
    dd if=/dev/zero of=$DIR-ipq806x-generic-netgear_r7800-initramfs-uImage bs=1K count=10
    dd if=/dev/zero of=$DIR-ipq806x-generic-netgear_r7800-squashfs-factory.img bs=1K count=10
    dd if=/dev/zero of=$DIR-ipq806x-generic-netgear_r7800-squashfs-sysupgrade.bin bs=1K count=10
    dd if=/dev/zero of=$DIR-ipq806x-generic-netgear_r7800.manifest bs=1K count=10
    dd if=/dev/zero of=config.buildinfo bs=1K count=10
    dd if=/dev/zero of=config.buildinfo bs=1K count=10
    dd if=/dev/zero of=config.buildinfo bs=1K count=10
    # RELEASE="FAKE"
}

###################################
#                                 #
#  FROM SETUP -> KITCHEN          #
#                                 #
###################################
makekitchen(){
    ! [ -e diff.config ] && cp .config diff.config
    make defconfig && make -j$(($(nproc)*2)) download && make -j$(($(nproc)*2)) {toolchain,target}/compile
}

###################################
#                                 #
#  CLEAN AFTER BUILD              #
#                                 #
###################################
cleankitchen(){ 
    rm -rf bin tmp build_dir/target*
    make defconfig && make oldconfig
}

###################################
#                                 #
#  DEVICE SETUP                   #
#                                 #
###################################

set_E8450() {
    DIR=E8450
    PROFILE=linksys_e8450-ubi
    RELEASE=snapshots
    TARGET=mediatek
    ARCH=mt7622
    DIFF_CONFIG=E8450.config
    # removed iptables-nft collectd-mod-entropy luci-app-unbound unbound-control -dnsmasq
    DIFF_PACKAGES="-odhcpd-ipv6only odhcpd luci-app-unbound unbound-control openssh-sftp-server -libustream-wolfssl -libwolfssl -wpad-basic-wolfssl 6in4 6rd 6to4 auc blockd ca-certificates ccrypt collectd-mod-conntrack collectd-mod-cpufreq collectd-mod-ipstatistics collectd-mod-ping collectd-mod-sqm collectd-mod-thermal collectd-mod-wireless cryptsetup curl ddns-scripts-noip diffutils e2fsprogs f2fs-tools gdbserver hostapd-utils htop ip6tables-mod-nat ip6tables-nft iperf3 iptables-mod-extra irqbalance kmod-fs-cifs kmod-fs-exfat kmod-fs-ext4 kmod-fs-f2fs kmod-fs-hfs kmod-fs-hfsplus kmod-fs-msdos kmod-fs-nfs-v3 kmod-fs-nfs-v4 kmod-nls-cp1250 kmod-nls-cp850 kmod-nls-iso8859-15 kmod-usb-storage-uas luci-app-adblock luci-app-argon-config luci-app-attendedsysupgrade luci-app-banip luci-app-bcp38 luci-app-commands luci-app-ddns luci-app-nlbwmon luci-app-openvpn luci-app-sqm luci-app-statistics luci-app-ttyd luci-app-uhttpd luci-app-upnp luci-app-vnstat2 luci-app-wireguard luci-ssl-openssl luci-theme-argon mc nano-full ncdu nfs-utils ntfs-3g openvpn-openssl patch ppp-mod-pptp tc-mod-iptables tcpdump-mini tor tree wget-ssl wpad-openssl"
    REPO=
    BRANCH=
    dl_ow $DIR $REPO $BRANCH
    set_packages "$DIFF_PACKAGES"
    add_argon
    add_nano-full
}

set_E8450old() {
    DIR=E8450
    PROFILE=linksys_e8450-ubi
    RELEASE=snapshots
    TARGET=mediatek
    ARCH=mt7622
    DIFF_CONFIG=E8450old.config
    DIFF_PACKAGES="openvpn-openssl tor iptables-mod-extra mc nano-full htop ncdu iperf3 irqbalance auc ca-certificates ca-buldle -wpad-basic-wolfssl -libustream-wolfssl -px5g-wolfssl wpad-openssl libustream-openssl luci-ssl-openssl luci luci-compat luci-app-attendedsysupgrade luci-app-vnstat2 luci-app-nlbwmon luci-app-adblock luci-app-banip luci-app-bcp38 luci-app-commands luci-app-ddns ddns-scripts-noip luci-app-openvpn luci-ssl-openssl luci-app-sqm luci-app-wireguard luci-app-upnp luci-app-uhttpd luci-app-statistics collectd-mod-conntrack collectd-mod-cpu collectd-mod-cpufreq collectd-mod-dhcpleases collectd-mod-entropy collectd-mod-exec collectd-mod-interface collectd-mod-iwinfo collectd-mod-load collectd-mod-memory collectd-mod-network collectd-mod-ping collectd-mod-rrdtool collectd-mod-sqm collectd-mod-thermal collectd-mod-uptime collectd-mod-wireless blockd cryptsetup e2fsprogs f2fs-tools kmod-fs-exfat kmod-fs-ext4 kmod-fs-f2fs kmod-fs-hfs kmod-fs-hfsplus kmod-fs-msdos kmod-fs-nfs kmod-fs-nfs-common kmod-fs-nfs-v3 kmod-fs-nfs-v4 kmod-fs-vfat kmod-nls-base kmod-nls-cp1250 kmod-nls-cp437 kmod-nls-cp850 kmod-nls-iso8859-1 kmod-nls-iso8859-15 kmod-nls-utf8 kmod-usb-storage kmod-usb-storage-uas libblkid ntfs-3g nfs-utils ip6tables-mod-nat 6in4 6rd 6to4 ip6tables-nft luci-app-ttyd"
    REPO=
    BRANCH=
    dl_ow $DIR $REPO $BRANCH
    set_packages "$DIFF_PACKAGES"
    add_argon
    add_nano-full
}

set_R6020() {
    DIR=R6020
    PROFILE="netgear_r6020"
    RELEASE="snapshots"
    TARGET="ramips"
    ARCH="mt76x8"
    DIFF_PACKAGES="luci"     
    # nano-plus htop iperf3 luci wpad-mesh-wolfssl -wpad-basic-wolfssl luci-app-vnstat2 luci-app-nlbwmon"
    DIFF_CONFIG=R6020.config
    REPO=https://github.com/openwrt/openwrt
    BRANCH=openwrt-22.03
    dl_ow $DIR $REPO $BRANCH
    set_packages "$DIFF_PACKAGES"
#    add_argon
#    add_nano-full
}

set_R6020nocss() {
    DIR=R6020nocss
    PROFILE="netgear_r6020"
    RELEASE="snapshots"
    TARGET="ramips"
    ARCH="mt76x8"
    DIFF_PACKAGES="luci"     
    # nano-plus htop iperf3 luci wpad-mesh-wolfssl -wpad-basic-wolfssl luci-app-vnstat2 luci-app-nlbwmon"
    DIFF_CONFIG=R6020nocss.config
    REPO=https://github.com/openwrt/openwrt
    BRANCH=openwrt-22.03
    dl_ow $DIR $REPO $BRANCH
    set_packages "$DIFF_PACKAGES"
#    add_argon
#    add_nano-full
}

set_R7800() {
    DIR=R7800
    PROFILE="netgear_r7800"
    RELEASE="snapshots"
    TARGET="ipq806x"
    ARCH="generic"
    DIFF_CONFIG="R7800.config"
    DIFF_PACKAGES="openssh-sftp-server -libustream-wolfssl -libwolfssl -wpad-basic-wolfssl 6in4 6rd 6to4 auc blockd ca-certificates ccrypt collectd-mod-conntrack collectd-mod-cpufreq collectd-mod-ipstatistics collectd-mod-ping collectd-mod-sqm collectd-mod-thermal -collectd-mod-uptime collectd-mod-wireless cryptsetup curl ddns-scripts-noip diffutils e2fsprogs f2fs-tools gdbserver hostapd-utils htop ip6tables-mod-nat ip6tables-nft iperf3 iptables-mod-extra irqbalance kmod-fs-cifs kmod-fs-exfat kmod-fs-ext4 kmod-fs-f2fs kmod-fs-hfs kmod-fs-hfsplus kmod-fs-msdos kmod-fs-nfs-v3 kmod-fs-nfs-v4 kmod-nls-cp1250 kmod-nls-cp850 kmod-nls-iso8859-15 kmod-usb-storage-uas luci-app-adblock luci-app-argon-config luci-app-attendedsysupgrade luci-app-banip luci-app-bcp38 luci-app-commands luci-app-ddns luci-app-nlbwmon luci-app-openvpn luci-app-sqm luci-app-statistics luci-app-ttyd luci-app-uhttpd luci-app-upnp luci-app-vnstat2 luci-app-wireguard luci-ssl-openssl luci-theme-argon mc nano-full ncdu nfs-utils ntfs-3g openvpn-openssl patch ppp-mod-pptp tc-mod-iptables tcpdump-mini tor tree wget-ssl wpad-openssl"
    REPO=
    BRANCH=
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
    DIFF_PACKAGES="nano-full htop ncdu iperf3 irqbalance auc luci luci-compat luci-mod-dashboard luci-app-attendedsysupgrade luci-theme-argon luci-app-argon-config luci-app-ttyd luci-app-vnstat2 luci-app-nlbwmon"
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
    cp ~/work/myopenwrt/myopenwrt/files/etc/nanorc ~/.nanorc
    echo "EXPORTING CONFIGURATION TO GITHUB ACTION $GITHUB_RUN_NUMBER"
    echo "PROFILE=$PROFILE" >>$GITHUB_ENV
    echo "TARGET=$TARGET" >>$GITHUB_ENV
    echo "ARCH=$ARCH" >>$GITHUB_ENV
    echo "RELEASE=$RELEASE" >>$GITHUB_ENV
    echo "DIFF_PACKAGES=$DIFF_PACKAGES" >>$GITHUB_ENV
    echo "DIFF_CONFIG=$DIFF_CONFIG" >>$GITHUB_ENV
    echo "REPO=$REPO" >>$GITHUB_ENV
    echo "BRANCH=$BRANCH" >>$GITHUB_ENV
    echo "LAST_PWD=$PWD" >>$GITHUB_ENV
    echo "PROFILE=$PROFILE"
    echo "TARGET=$TARGET"
    echo "ARCH=$ARCH"
    echo "RELEASE=$RELEASE"
    echo "DIFF_CONFIG=$DIFF_CONFIG"
    echo "DIFF_PACKAGES=$DIFF_PACKAGES"
    echo "REPO=$REPO"
    echo "BRANCH=$BRANCH"
    echo "LAST_PWD=$PWD"
fi
